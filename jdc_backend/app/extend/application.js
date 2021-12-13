"use strict";

const { readFile, writeFile } = require("fs").promises;
const path = require("path");
const dayjs = require("dayjs");
const isBetween = require("dayjs/plugin/isBetween");
const utc = require("dayjs/plugin/utc");
const timezone = require("dayjs/plugin/timezone");
dayjs.extend(isBetween);
dayjs.extend(utc);
dayjs.extend(timezone);
dayjs.tz.setDefault("Asia/Shanghai");
const { v4: uuidv4 } = require("uuid");

const { randonUserAgent, delay } = require("./helper");
const filePath = path.join(process.cwd(), "config.json");

module.exports = {
    async getConfig(type) {
        let configFile = await readFile(filePath, { encoding: "utf-8" });
        let config = JSON.parse(configFile);
        return config[type];
    },

    async getNode(client_url) {
        let res = await this.getConfig("nodeList");

        let node = res.filter((item) => {
            return item.client_url == client_url;
        })[0];
        return node;
    },

    async getToken(client_url) {
        // 判断文件中是否有token
        let { client_id, client_secret, token, expire } = await this.getNode(client_url);
        if (token) {
            if (dayjs().isBefore(dayjs(expire).add(3, "day"))) {
                return token;
            }
        }
        // 改为新的openApi
        const body = await this.curl(`${client_url}/open/auth/token`, {
            headers: {
                Accept: "application/json"
            },
            data: {
                client_id,
                client_secret
            },
            contentType: "json",
            dataType: "json"
        });
        if (body.status === 200) {
            let res = await this.getConfig("nodeList");
            for (let i = 0; i < res.length; i++) {
                const element = res[i];
                if (element.client_url == client_url) {
                    res[i]["token"] = body.data.data.token;
                    res[i]["expire"] = dayjs();
                }
            }
            // 写入文件
            await writeFile(filePath, JSON.stringify(res));
            return body.data.data.token;
        }
        return "";
        // const qlDir = this.config.QL_DIR || "/ql";
        // const authFile = path.join(process.cwd() + qlDir, "config/auth.json");
        // const authConfig = JSON.parse(await readFile(authFile));
        // return authConfig.token;
    },

    async envHelper(client_url) {
        const token = await this.getToken(client_url);
        const body = await this.curl(`${client_url}/open/envs?searchValue=JD_COOKIE&t=${Date.now()}`, {
            headers: {
                Accept: "application/json",
                authorization: `Bearer ${token}`
            },
            dataType: "json"
        });
        if (body.status == 200) {
            return body.data.data;
        }
        return [];
    },

    async getPoolInfo(client_url) {
        let envs = await this.envHelper(client_url);
        const count = envs.length;
        if (count > 0) {
            const allowCount = (this.config.ALLOW_NUM || 40) - count;
            return {
                code: 1,
                result: {
                    marginCount: allowCount >= 0 ? allowCount : 0,
                    allowAdd: Boolean(this.config.ALLOW_ADD) || true,
                    allCount: this.config.ALLOW_NUM
                }
            };
        } else {
            return {
                code: 0,
                result: {
                    marginCount: 0,
                    allowAdd: Boolean(this.config.ALLOW_ADD) || true,
                    allCount: this.config.ALLOW_NUM
                }
            };
        }
    },

    async CKLogin(currentCookie, pt_pin, client_url, notify = true) {
        let message, eid;
        let nickname = await this.getNicknameOrBean(currentCookie);
        if (nickname == "") {
            throw new qlError("获取用户信息失败，请检查您的 cookie ！", -1, 200);
        }
        const envs = await this.envHelper(client_url);
        const poolInfo = await this.getPoolInfo(client_url);
        const env = await envs.find((item) => item.value.match(/pt_pin=(.*?);/)[1] === pt_pin);
        if (!env) {
            // 新用户
            if (!poolInfo.allowAdd) {
                throw new qlError("管理员已关闭注册，去其他地方看看吧", -1, 200);
            } else if (poolInfo.marginCount === 0) {
                throw new qlError("本站已到达注册上限，你来晚啦", -1, 200);
            } else {
                let result = await this.addEnv(currentCookie, nickname, client_url);
                eid = result[0]._id;
                message = `添加成功，可以愉快的白嫖啦 ${nickname}`;
                const pt_pin = currentCookie.match(/pt_pin=(.*?);/)[1];
                // 发送通知
                notify && this.sendNotify("egg_jdc 运行通知", `用户 ${nickname}(${decodeURIComponent(pt_pin)}) 已上线"`);
            }
        } else {
            eid = env._id;
            const body = await this.updateEnv(currentCookie, eid, env.remarks, client_url);
            if (body.code !== 200) {
                throw new qlError(body.message || "更新账户错误，请重试", -1, 200);
            }
            message = `欢迎回来，${nickname}`;
            const pt_pin = currentCookie.match(/pt_pin=(.*?);/)[1];
            notify && this.sendNotify("egg_jdc 运行通知", `用户 ${env.remarks || nickname}(${decodeURIComponent(pt_pin)}) 已更新 CK"`);
            this.enabledEnv(eid, client_url);
        }
        return {
            code: 0,
            eid: eid,
            timestamp: dayjs().format("YYYY-MM-DD HH:hh:mm"),
            message
        };
    },

    async getNicknameOrBean(currentCookie, bean) {
        const { data: result } = await this.curl(`https://me-api.jd.com/user_new/info/GetJDUserInfoUnion`, {
            headers: {
                Accept: "*/*",
                "Accept-Encoding": "gzip, deflate, br",
                "Accept-Language": "zh-cn",
                Connection: "keep-alive",
                Cookie: currentCookie,
                Referer: "https://home.m.jd.com/myJd/newhome.action",
                "User-Agent": randonUserAgent(),
                Host: "me-api.jd.com"
            },
            dataType: "json"
        });
        if (result.retcode === "0") {
            if (bean) {
                return {
                    nickName: result.data.userInfo.baseInfo.nickname,
                    beanNum: result.data.assetInfo.beanNum
                };
            } else {
                return result.data.userInfo.baseInfo.nickname;
            }
        }
        this.logger.info(`获取用户信息失败，请检查您的 cookie ！`);
        return "";
    },
    async runCorn(id, client_url) {
        const token = await this.getToken(client_url);
        const body = await this.curl(`${client_url}/open/crons/run?t=${Date.now()}`, {
            method: "PUT",
            contentType: "json",
            dataType: "json",
            data: [id],
            headers: {
                Accept: "application/json",
                authorization: `Bearer ${token}`,
                "Content-Type": "application/json;charset=UTF-8"
            }
        });
        if (body.data.code !== 200) {
            throw new qlError(body.message || "定时任务运行失败", -1, 200);
        }
        return "定时任务运行成功";
    },
    async addEnv(cookie, nickname, client_url) {
        const token = await this.getToken(client_url);
        const body = await this.curl(`${client_url}/open/envs?t=${Date.now()}`, {
            method: "POST",
            contentType: "json",
            dataType: "json",
            data: [
                {
                    name: "JD_COOKIE",
                    value: cookie,
                    remarks: nickname
                }
            ],
            headers: {
                Accept: "application/json",
                authorization: `Bearer ${token}`,
                "Content-Type": "application/json;charset=UTF-8"
            }
        });
        if (body.data.code !== 200) {
            throw new qlError(body.message || "添加账户错误，请重试", -1, 200);
        }
        return body.data.data;
    },
    async updateEnv(cookie, eid, remarks, client_url) {
        const token = await this.getToken(client_url);
        const body = await this.curl(`${client_url}/open/envs?t=${Date.now()}`, {
            method: "PUT",
            contentType: "json",
            dataType: "json",
            data: {
                name: "JD_COOKIE",
                value: cookie,
                _id: eid,
                remarks
            },
            headers: {
                Accept: "application/json",
                authorization: `Bearer ${token}`,
                "Content-Type": "application/json;charset=UTF-8"
            }
        });
        return body.data;
    },
    async delEnv(eid, client_url) {
        const token = await this.getToken(client_url);
        const body = await this.curl(`${client_url}/open/envs?t=${Date.now()}`, {
            method: "DELETE",
            data: [eid],
            dataType: "json",
            headers: {
                Accept: "application/json",
                authorization: `Bearer ${token}`,
                "Content-Type": "application/json;charset=UTF-8"
            }
        });
        return body.data;
    },
    async disableEnv(eid, client_url) {
        const token = await this.getToken(client_url);
        const body = await this.curl(`${client_url}/open/envs/disable?t=${Date.now()}`, {
            method: "PUT",
            data: [eid],
            dataType: "json",
            headers: {
                Accept: "application/json",
                authorization: `Bearer ${token}`,
                "Content-Type": "application/json;charset=UTF-8"
            }
        });
        return body.data;
    },

    async enabledEnv(eid, client_url) {
        const token = await this.getToken(client_url);
        const body = await this.curl(`${client_url}/open/envs/enable?t=${Date.now()}`, {
            method: "PUT",
            data: [eid],
            dataType: "json",
            headers: {
                Accept: "application/json",
                authorization: `Bearer ${token}`,
                "Content-Type": "application/json;charset=UTF-8"
            }
        });
        return body.data;
    },

    async getEnv(eid, client_url) {
        const token = await this.getToken(client_url);
        const body = await this.curl(`${client_url}/open/envs/${eid}?t=${Date.now()}`, {
            dataType: "json",
            headers: {
                Accept: "application/json",
                authorization: `Bearer ${token}`,
                "Content-Type": "application/json;charset=UTF-8"
            }
        });
        return body.data;
    },

    formatSetCookies(headers, body) {
        let guid, lsid, ls_token, cookqr, s_token;
        s_token = body.s_token;
        guid = headers["set-cookie"][0];
        guid = guid.substring(guid.indexOf("=") + 1, guid.indexOf(";"));
        lsid = headers["set-cookie"][2];
        lsid = lsid.substring(lsid.indexOf("=") + 1, lsid.indexOf(";"));
        ls_token = headers["set-cookie"][3];
        ls_token = ls_token.substring(ls_token.indexOf("=") + 1, ls_token.indexOf(";"));
        cookqr = `guid=${guid};lang=chs;lsid=${lsid};ls_token=${ls_token};`;
        return {
            s_token,
            cookqr
        };
    },

    async getUserInfoByEid(eid, client_url) {
        const envs = await this.envHelper(client_url);
        const env = await envs.find((item) => item._id === eid);
        if (!env) {
            throw new qlError("没有找到这个账户，重新登录试试看哦", -1, 200);
        }
        const currentCookie = env.value;
        const remarks = env.remarks;
        let remark = "";
        if (remarks) {
            remark = remarks.match(/remark=(.*?);/) && remarks.match(/remark=(.*?);/)[1];
        }
        let nickName = await this.getNicknameOrBean(currentCookie);
        return {
            nickName,
            eid,
            timestamp: dayjs(env.timestamp).format("YYYY-MM-DD HH:hh:mm"),
            remark,
            status: env.status
        };
    },

    async updateRemark(eid, remark, client_url) {
        if (!eid || !remark || remark.replace(/(^\s*)|(\s*$)/g, "") === "") {
            throw new qlError("参数错误", -1, 200);
        }

        const envs = await this.envHelper(client_url);
        const env = await envs.find((item) => item._id === this.eid);
        if (!env) {
            throw new qlError("没有找到这个账户，重新登录试试看哦", -1, 200);
        }

        const remarks = `remark=${this.remark};`;

        const updateEnvBody = await this.updateEnv(env.value, this.eid, remarks, client_url);
        if (updateEnvBody.code !== 200) {
            throw new qlError("更新/上传备注出错，请重试", -1, 200);
        }

        return {
            code: 0,
            message: "更新/上传备注成功"
        };
    },

    async delUserByEid(eid, client_url) {
        const body = await this.delEnv(eid, client_url);
        if (body.code !== 200) {
            throw new qlError(body.message || "删除账户错误，请重试", -1, 200);
        }
        let { nickName, pt_pin } = await this.getUserInfoByEid(eid, client_url);
        this.sendNotify("egg_jdc 运行通知", `用户 ${nickName}(${decodeURIComponent(pt_pin)}) 删号跑路了"`);
        return {
            code: 0,
            message: "账户已移除"
        };
    },

    async getJingBeanBalanceDetail(page, cookie) {
        const body = await this.curl(`https://api.m.jd.com/client.action?functionId=getJingBeanBalanceDetail`, {
            method: "POST",
            headers: {
                "User-Agent":
                    "jdapp;iPhone;9.4.4;14.3;network/4g;Mozilla/5.0 (iPhone; CPU iPhone OS 14_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148;supportJDSHWK/1",
                Host: "api.m.jd.com",
                "Content-Type": "application/x-www-form-urlencoded",
                Cookie: cookie
            },
            data: {
                body: JSON.stringify({ pageSize: "1000", page: page.toString() }),
                appid: "ld"
            },
            dataType: "json"
        });
        return body.data.detailList;
    },

    async sendNotify(title, content) {
        if (!this.config.NOTIFY) {
            this.logger.info("egg_jdc 通知已关闭\n" + title + "\n" + content + "\n" + "已跳过发送");
            return "egg_jdc 通知已关闭\n" + title + "\n" + content + "\n" + "已跳过发送";
        }
        await this.pushPlusNotify(title, content);
    },

    async pushPlusNotify(text, desp) {
        if (this.config.PUSH_PLUS_TOKEN) {
            let content = desp.replace(/[\n\r]/g, "<br>"); // 默认为html, 不支持plaintext
            const body = {
                token: `${this.config.PUSH_PLUS_TOKEN}`,
                title: `${text}`,
                content: `${content}`,
                topic: `${this.config.PUSH_PLUS_USER}`
            };
            try {
                let res = await this.curl("https://www.pushplus.plus/send", {
                    method: "POST",
                    contentType: "json",
                    dataType: "json",
                    data: body,
                    headers: {
                        "Content-Type": " application/json"
                    }
                });
                if (res.data.code === 200) {
                    this.logger.info(`push+发送${this.config.PUSH_PLUS_USER ? "一对多" : "一对一"}通知消息完成。\n`);
                } else {
                    this.logger.info(`push+发送${this.config.PUSH_PLUS_USER ? "一对多" : "一对一"}通知消息失败：${res.data.msg}\n`);
                }
            } catch (error) {
                this.logger.info(`push+发送${this.config.PUSH_PLUS_USER ? "一对多" : "一对一"}通知消息失败！！\n`);
                this.logger.info(err);
            } finally {
                return;
            }
        } else {
            this.logger.warn("没有填写push_token");
            return;
        }
    },

    async gobotNotify(text, desp) {
        if (this.config.GOBOT_URL) {
            try {
                let res = await this.curl(`${this.config.GOBOT_URL}?access_token=${this.config.GOBOT_TOKEN}&${this.config.GOBOT_QQ}`, {
                    method: "POST",
                    contentType: "json",
                    dataType: "json",
                    data: { message: `${text}\n${desp}` },
                    headers: {
                        "Content-Type": " application/json"
                    }
                });

                if (res.retcode === 0) {
                    this.logger.info("go-cqhttp发送通知消息成功🎉\n");
                } else if (res.retcode === 100) {
                    this.logger.info(`go-cqhttp发送通知消息异常: ${res.errmsg}\n`);
                } else {
                    this.logger.info(`go-cqhttp发送通知消息异常\n${res}`);
                }
            } catch (error) {
                this.logger.info("发送go-cqhttp通知调用API失败！！\n");
                this.logger.info(err);
            } finally {
                return;
            }
        } else {
            this.logger.warn("没有填写GOBOT_URL");
            return;
        }
    },

    async serverNotify(text, desp) {
        if (this.config.SCKEY) {
            try {
                let res = await this.curl(
                    this.config.SCKEY.includes("SCT") ? `https://sctapi.ftqq.com/${this.config.SCKEY}.send` : `https://sc.ftqq.com/${this.config.SCKEY}.send`,
                    {
                        method: "POST",
                        dataType: "json",
                        data: {
                            text,
                            desp
                        },
                        headers: {
                            "Content-Type": " application/x-www-form-urlencoded"
                        }
                    }
                );

                if (res.errno === 0 || res.data.errno === 0) {
                    this.logger.info("server酱发送通知消息成功🎉\n");
                } else if (res.errno === 1024) {
                    // 一分钟内发送相同的内容会触发
                    this.logger.info(`server酱发送通知消息异常: ${res.errmsg}\n`);
                } else {
                    this.logger.info(`server酱发送通知消息异常\n${res}`);
                }
            } catch (error) {
                this.logger.info("发送通知调用API失败！！\n");
                this.logger.info(err);
            } finally {
                return;
            }
        } else {
            this.logger.warn("没有填写SCKEY");
            return;
        }
    },

    async checkCookie() {
        this.logger.info(`检查cookie-----`);
        let res = await this.getConfig("nodeList");
        let disNum = 0;
        for (const iterator of res) {
            const envs = await this.envHelper(iterator.client_url);
            for (const env of envs) {
                const pt_pin = env.value.match(/pt_pin=(.*?);/)[1];
                let nickname;
                if (env.status === 0) {
                    nickname = await this.getNicknameOrBean(env.value);
                }

                if (!nickname && env.status != 1) {
                    await this.disableEnv(env._id, iterator.client_url);
                    await this.sendNotify(`禁用cookie--${nickname}(${decodeURIComponent(pt_pin)})`, env.value);
                    // 只能刷新wskey的节点
                    await this.updateOneCok(env.value, iterator.client_url);
                    disNum++;
                }
            }
        }
        if (disNum) {
            this.logger.info(`监测${disNum}个账号异常, 并已经处理, 请查看通知!`);
        } else {
            this.logger.info(`太棒了,没有账号异常!`);
        }
    },

    async updateOneCok(cookie, client_url) {
        // 根据pt_pin 查询wskey
        const pt_pin = cookie.match(/pt_pin=(.*?);/)[1];
        const wskey = cookie.match(/wskey=(.*?);/);
        if (pt_pin && wskey && wskey.length > 0) {
            await delay(5 * 1000);
            let updateRes = await this.fakeToken(pt_pin, wskey[1]);
            if (updateRes) {
                await this.CKLogin(`${updateRes}`, pt_pin, client_url);
            } else {
                this.sendNotify(`更新失败--(${decodeURIComponent(pt_pin)})`, "");
            }
        } else {
            this.logger.info(`pt_pin=${pt_pin} 没有配置wskey 无法更新`);
        }
    },

    async updateCookie() {
        let res = await this.getConfig("nodeList");
        let message = [];
        for (const iterator of res) {
            const envs = await this.envHelper(iterator.client_url);
            let faileEnv = [];
            for (const env of envs) {
                const pt_pin = env.value.match(/pt_pin=(.*?);/)[1];
                const wskey = env.value.match(/wskey=(.*?);/);
                if (pt_pin && wskey && wskey.length > 0) {
                    await delay(5 * 1000);
                    let updateRes = await this.fakeToken(pt_pin, wskey[1]);
                    if (updateRes) {
                        await this.CKLogin(`${updateRes}`, pt_pin, iterator.client_url, false);
                        this.logger.info(`pt_pin=${pt_pin} 更新成功！`);
                        message.push(`pt_pin=${pt_pin} 更新成功！`);
                    } else {
                        let repeatCk = {
                            pt_pin,
                            wskey: wskey[1]
                        };
                        this.logger.info(`pt_pin=${pt_pin} 更新失败 进入重试队列`);
                        message.push(`pt_pin=${pt_pin} 更新失败！`);
                        faileEnv.push(repeatCk);
                    }
                } else {
                    message.push(`pt_pin=${pt_pin} 没有配置wskey 无法更新`);
                    this.logger.info(`pt_pin=${pt_pin} 没有配置wskey 无法更新`);
                }
            }
            if (faileEnv.length > 0) {
                await this.repeatCk(iterator.client_url, faileEnv);
            }
        }
        await this.sendNotify(`更新通知`, message.join("\n"));
        return message;
    },

    async repeatCk(url, faileEnv) {
        let message = ["开始重试.... 只重试一次"];
        this.logger.info("开始重试.... 只重试一次");
        for (let i = 0; i < faileEnv.length; i++) {
            const element = faileEnv[i];
            let { pt_pin, wskey } = element;
            await delay(5 * 1000);
            let updateRes = await this.fakeToken(pt_pin, wskey);
            if (updateRes) {
                await this.CKLogin(`${updateRes}`, pt_pin, url, false);
                message.push(`pt_pin=${pt_pin} 更新成功！`);
            } else {
                message.push(`pt_pin=${pt_pin} 更新失败！`);
            }
        }
        await this.sendNotify(`重试更新通知`, message.join("\n"));
    },

    async addCookieWs(value, client_url) {
        const pt_pin = value.match(/pin=(.*?);/);
        const wskey = value.match(/wskey=(.*?);/);
        if (wskey && wskey.length > 0 && pt_pin && pt_pin.length > 0) {
            let updateRes = await this.fakeToken(pt_pin[1], wskey[1]);
            if (!updateRes) {
                this.sendNotify(`更新失败`, `(${decodeURIComponent(pt_pin[1])})`);
                throw new qlError(`pt_pin=${pt_pin[1]} 没有配置wskey 无法更新`, -1, 200);
            }
            return await this.CKLogin(`${updateRes}`, pt_pin[1], client_url);
        } else {
            this.logger.info(`pt_pin=${pt_pin[1]} 没有配置wskey 无法更新`);
            throw new qlError(`pt_pin=${pt_pin[1]} 没有配置wskey 无法更新`, -1, 200);
        }
    },
    // 获取sign
    async getSign() {
        // let functionId = "genToken";
        // let client = "android";
        // let clientVersion = "10.1.2";
        // let body = "%7B%22to%22%3A%22https%253a%252f%252fplogin.m.jd.com%252fjd-mlogin%252fstatic%252fhtml%252fappjmp_blank.html%22%7D";
        // let signRes = await this.curl(`http://jd.zack.xin/sign.php?functionId=${functionId}&client=${client}&clientVersion=${clientVersion}&uuid=${uuid}&body=${body}`, {
        //     dataType: "json"
        // });
        if (dayjs().isBefore(dayjs(this.config.FAKESIGNEXPIRE).add(1, "day"))) {
            return this.config.FAKESIGN;
        } else {
            try {
                let body = { url: "https://home.m.jd.com/myJd/newhome.action" };
                let signRes = await this.curl(`https://api.jds.codes/gentoken`, {
                    method: "POST",
                    data: body,
                    method: "POST",
                    headers: {
                        "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.63 Safari/537.36 Edg/93.0.961.38",
                        "Content-Type": "application/json"
                    },
                    contentType: "json",
                    dataType: "json"
                });

                this.config.FAKESIGN = body.data.data.token;
                this.config.FAKESIGNEXPIRE = dayjs();
                return signRes.data.data.sign;
            } catch (error) {
                return this.config.FAKESIGN;
            }
        }
    },
    async fakeToken(pin, wskey) {
        let signResult = await this.getSign();
        let postRe = signResult.split("&");
        let body = postRe[0];
        let jduuid = postRe[1];
        let client = postRe[2];
        let clientVersion = postRe[3];
        let sign = `${postRe[4]}&${postRe[5]}&${postRe[6]}`;
        let url = `https://api.m.jd.com/client.action?functionId=genToken&${clientVersion}&${client}&${jduuid}&${sign}`;
        let resT = await this.curl(url, {
            method: "POST",
            data: body,
            headers: {
                Host: "api.m.jd.com",
                "user-agent": "okhttp/3.12.1;jdmall;apple;version/9.4.0;build/88830;screen/1440x3007;os/11;network/wifi" + uuidv4(),
                "content-type": "application/x-www-form-urlencoded;charset=UTF-8",
                Cookie: `pin=${pin};wskey=${wskey};`
            },
            dataType: "json"
        });
        let ptKey = "";
        if (Number(resT.data.code) === 0) {
            let token = resT.data.tokenKey;
            let url = resT.data.url;
            let res = await this.curl(`${url}?tokenKey=${token}&https://home.m.jd.com/myJd/newhome.action`, {
                headers: {
                    Connection: "Keep-Alive",
                    "Content-Type": "application/x-www-form-urlencoded",
                    Accept: "application/json, text/plain, */*",
                    "Accept-Language": "zh-cn",
                    "User-Agent": "okhttp/3.12.1;jdmall;apple;version/9.4.0;build/88830;screen/1440x3007;os/11;network/wifi;" + uuidv4()
                }
            });

            let test = new RegExp("pt_key=.*?;", "i");
            let keyArry = test.exec(res.headers["set-cookie"].join(";"));
            ptKey = keyArry[0];
            return `pt_pin=${pin};${ptKey}`;
        } else {
            return ``;
        }
    }
};

class qlError extends Error {
    constructor(message, code, statusCode) {
        super(message);
        this.name = "qlError";
        this.code = code;
        this.statusCode = statusCode || 200;
    }
}

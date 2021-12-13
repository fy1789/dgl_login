"use strict";

const Controller = require("egg").Controller;
class HomeController extends Controller {
    async index() {
        this.ctx.response.success({
            message: "jdc backend is ready"
        });
    }
    // 节点列表
    async getNodeList() {
        console.log(this.app.keys);
        let result = await this.app.getConfig("nodeList");
        let filterRes = [];
        result.forEach((i, index) => {
            filterRes.push({
                client_url: result[index].client_url,
                client_name: result[index].client_name
            });
        });
        for (const iterator of result) {
            let nodeInfo = await this.app.getPoolInfo(iterator.client_url);
            let index = result.findIndex((v) => {
                return v.client_id == iterator.client_id;
            });
            filterRes[index] = Object.assign(nodeInfo.result, filterRes[index]);
            if (nodeInfo.code === 1) {
                // 设备在线
                filterRes[index]["activite"] = true;
            } else {
                filterRes[index]["activite"] = false;
            }
        }
        this.ctx.response.success({
            data: filterRes
        });
    }

    async getActivity() {
        const config = await this.app.getConfig("activity");
        this.ctx.response.success({
            data: config
        });
    }

    async getGonggao() {
        const config = await this.app.getConfig("gonggao");
        this.ctx.response.success({
            data: config
        });
    }

    async getBeanChange() {
        try {
            let result = await this.app.getTotalBean(this.ctx.query.type);
            this.ctx.response.success({
                data: result
            });
        } catch (error) {
            this.ctx.response.failure({
                code: -1,
                message: "接口限制, 访问失败!"
            });
        }
    }

    async getNodeInfo(url) {
        const { client_url } = this.ctx.query;
        try {
            let result = await this.app.getPoolInfo(client_url ? client_url : url);
            this.ctx.response.success({
                data: result
            });
        } catch (error) {
            this.ctx.response.failure({
                code: -1,
                message: "接口限制, 访问失败!"
            });
        }
    }

    async userInfo() {
        try {
            let { client_url, eid } = this.ctx.query;
            const { nickName, timestamp, remark, status } = await this.app.getUserInfoByEid(eid, client_url);
            this.ctx.response.success({
                data: {
                    nickName,
                    eid,
                    timestamp,
                    remark,
                    status
                }
            });
        } catch (error) {
            this.ctx.response.failure({
                code: error.code,
                message: error.message
            });
        }
    }

    async delAccount() {
        try {
            let { client_url } = this.ctx.query;
            let { eid } = this.ctx.request.body;
            let { message } = await this.app.delUserByEid(eid, client_url);
            this.ctx.response.success({
                message
            });
        } catch (error) {
            this.ctx.response.failure({
                code: error.code,
                message: error.message
            });
        }
    }

    async disableAccount() {
        try {
            let { client_url } = this.ctx.query;
            let { eid } = this.ctx.request.body;
            let { message } = await this.app.disableEnv(eid, client_url);
            this.ctx.response.success({
                message
            });
        } catch (error) {
            this.ctx.response.failure({
                code: error.code,
                message: error.message
            });
        }
    }
    async enableAccount() {
        try {
            let { client_url } = this.ctx.query;
            let { eid } = this.ctx.request.body;
            let { message } = await this.app.enabledEnv(eid, client_url);
            this.ctx.response.success({
                message
            });
        } catch (error) {
            this.ctx.response.failure({
                code: error.code,
                message: error.message
            });
        }
    }

    async updateMark() {
        try {
            let { client_url } = this.ctx.query;
            let { eid, remark } = this.ctx.request.body;
            await this.app.updateRemark(eid, remark, client_url);
            this.ctx.response.success({
                message
            });
        } catch (error) {
            this.ctx.response.failure({
                code: error.code,
                message: error.message
            });
        }
    }

    async updateCookie() {
        try {
            this.app.runSchedule("update_cookie");
            this.ctx.response.success({
                message: "定时任务执行成功!"
            });
        } catch (error) {
            this.ctx.response.failure({
                code: -1,
                message: "定时任务执行失败"
            });
        }
    }

    async saveCkLyq() {
        const { client_url } = this.ctx.query;
        const { value } = this.ctx.request.body;
        let cookie = decodeURIComponent(value);
        const pt_pin = cookie.match(/pt_pin=(.*?);/);
        const pt_key = cookie.match(/pt_key=(.*?);/);
        if (pt_key && pt_key.length > 0 && pt_pin && pt_pin.length > 0) {
            try {
                let res = await this.app.CKLogin(`${pt_pin[0]}${pt_key[0]}`, pt_pin[1], client_url);
                this.ctx.response.success({
                    data: res
                });
            } catch (error) {
                this.ctx.response.failure({
                    code: -1,
                    message: error.message
                });
            }
        } else {
            this.ctx.response.failure({
                code: -1,
                message: "无用 pt_pin, pt_key !!"
            });
        }
    }

    async addCookieWs() {
        try {
            let { client_url } = this.ctx.query;
            let { value } = this.ctx.request.body;
            let res = await this.app.addCookieWs(value, client_url);
            this.ctx.response.success({
                data: res
            });
        } catch (error) {
            this.ctx.response.failure({
                code: error.code,
                message: error.message
            });
        }
    }
}

module.exports = HomeController;

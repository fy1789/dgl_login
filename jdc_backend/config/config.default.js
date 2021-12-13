/* eslint valid-jsdoc: "off" */

"use strict";

const path = require("path");
/**
 * @param {Egg.EggAppInfo} appInfo app info
 */
module.exports = (appInfo) => {
    /**
     * built-in config
     * @type {Egg.EggAppConfig}
     **/
    const config = (exports = {});

    // use for cookie sign key, should change to your own and keep security
    config.keys = appInfo.name + "_1627433954076_3976";

    // add your middleware config here
    config.middleware = [];

    //静态文件修改
    config.static = {
        prefix: "/jdc",
        dir: path.join(appInfo.baseDir, "app/jdc")
    };

    // 配置端口
    config.cluster = {
        listen: {
            port: 9997,
            hostname: "0.0.0.0"
        }
    };

    config.httpclient = {
        request: {
            timeout: 30 * 1000
        }
    };

    // 取消安全证书验证
    config.security = {
        csrf: {
            enable: false
        },
        domainWhiteList: ["127.0.0.1"] // 白名单
    };
    //cors 配置
    config.cors = {
        origin: "*", // 跨任何域
        allowMethods: "GET,HEAD,PUT,POST,DELETE,PATCH,OPTIONS" // 被允许的请求方式
    };

    // add your user config here
    const userConfig = {
        FAKESIGN: "",
        FAKESIGNEXPIRE: "",
        ALLOW_NUM: 200, //节点最大提供cookie数量
        ALLOW_ADD: 1, //是否允许添加cookie
        NOTIFY: 1, //添加成功后,是否允许通知
        // =======================================push+设置区域=======================================
        //官方文档：http://www.pushplus.plus/
        //PUSH_PLUS_TOKEN：微信扫码登录后一对一推送或一对多推送下面的token(您的Token)，不提供PUSH_PLUS_USER则默认为一对一推送
        //PUSH_PLUS_USER： 一对多推送的“群组编码”（一对多推送下面->您的群组(如无则新建)->群组编码，如果您是创建群组人。也需点击“查看二维码”扫描绑定，否则不能接受群组消息推送）
        PUSH_PLUS_TOKEN: "",
        PUSH_PLUS_USER: "",
        // =======================================go-cqhttp通知设置区域===========================================
        //gobot_url 填写请求地址http://127.0.0.1/send_private_msg
        //gobot_token 填写在go-cqhttp文件设置的访问密钥
        //gobot_qq 填写推送到个人QQ或者QQ群号
        //go-cqhttp相关API https://docs.go-cqhttp.org/api
        GOBOT_URL: "", // 推送到个人QQ: http://127.0.0.1/send_private_msg  群：http://127.0.0.1/send_group_msg
        GOBOT_TOKEN: "", //访问密钥
        GOBOT_QQ: "", // 如果GOBOT_URL设置 /send_private_msg 则需要填入 user_id=个人QQ 相反如果是 /send_group_msg 则需要填入 group_id=QQ群

        // =======================================微信server酱通知设置区域===========================================
        //此处填你申请的SCKEY.
        //(环境变量名 PUSH_KEY)
        SCKEY: ""
    };
    return {
        ...config,
        ...userConfig
    };
};

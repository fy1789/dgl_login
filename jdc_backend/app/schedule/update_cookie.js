"use strict";
const { Subscription } = require("egg");

class UpdateCookie extends Subscription {
    // 通过 schedule 属性来设置定时任务的执行间隔等配置
    static get schedule() {
        return {
            cron: "20 10,22 * * *",
            type: "worker",
            env: ["prod"]
        };
    }

    // subscribe 是真正定时任务执行时被运行的函数
    async subscribe() {
        await this.app.updateCookie();
    }
}

module.exports = UpdateCookie;

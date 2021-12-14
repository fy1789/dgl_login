"use strict";

const Controller = require("egg").Controller;
class SmsController extends Controller {
    async index() {
        const { ctx, app } = this;
        if (!ctx.websocket) {
            throw new Error("this function can only be use in websocket router");
        }

        console.log("client connected");

        ctx.websocket
            .on("message", (msg) => {
                console.log("receive", msg);
            })
            .on("close", (code, reason) => {
                console.log("websocket closed", code, reason);
            });
        ctx.websocket.send("hhhh");
    }
}

module.exports = SmsController;

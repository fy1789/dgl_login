"use strict";

const { app, assert } = require("egg-mock/bootstrap");

describe("test/app/controller/home.test.js", () => {
    it("should assert", () => {
        const pkg = require("../../../package.json");
        assert(app.config.keys.startsWith(pkg.name));

        // const ctx = app.mockContext({});
        // yield ctx.service.xx();
    });

    it("should GET /api/userInfo", async () => {
        const result = await app.httpRequest().get("/api/userInfo?eid=xxx&client_url=xxxx").expect(200);
        app.httpRequest().post({});
        assert(result.body.result.nickName === "好大个栗子啊");
    });
});

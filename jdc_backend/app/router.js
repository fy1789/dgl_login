"use strict";

/**
 * @param {Egg.Application} app - egg application
 */
module.exports = (app) => {
    const { router, controller } = app;
    router.get("/", controller.home.index);
    router.get("/api/userInfo", controller.home.userInfo);
    router.delete("/api/delaccount", controller.home.delAccount);
    router.put("/api/disableaccount", controller.home.disableAccount);
    router.put("/api/enableaccount", controller.home.enableAccount);
    router.put("/api/updateRemark", controller.home.updateMark);
    router.get("/api/getBeanChange", controller.home.getBeanChange);
    router.get("/api/getNodeInfo", controller.home.getNodeInfo);
    router.get("/api/getNodeList", controller.home.getNodeList);
    router.get("/api/getActivity", controller.home.getActivity);
    router.get("/api/getGonggao", controller.home.getGonggao);
    router.post("/api/saveCkLyq", controller.home.saveCkLyq);
    router.post("/api/saveCkWs", controller.home.addCookieWs);

    app.ws.route("/", app.controller.sms.index);
};

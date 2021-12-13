# jdc_backend


## 开始


<!-- add docs here for user -->
* 默认端口地址为9700 可在 config/config.default.js
```json
// 配置端口
config.cluster = {
    listen: {
        port: 9997,// 端口号
        hostname: "0.0.0.0"
    }
};
```

* 内部有两个定时任务
  ***
  * check_cookie 定时检查并禁用cookie
  * update_cookie 定时刷新wskey对应的cookie

* 下载本项目 确保nodejs为最新版本
* 配置文件 config.json
```json
    {
    "gonggao": "本产品免费,github可下载源码",
    "activity": [
        {
            "name": "玩一玩（可找到大多数活动）",
            "address": "京东 APP 首页-频道-边玩边赚",
            "href": "https://funearth.m.jd.com/babelDiy/Zeus/3BB1rymVZUo4XmicATEUSDUgHZND/index.html"
        },
        {
            "name": "宠汪汪",
            "address": "京东APP-首页/玩一玩/我的-宠汪汪"
        },
        {
            "name": "东东萌宠",
            "address": "京东APP-首页/玩一玩/我的-东东萌宠"
        },
        {
            "name": "东东农场",
            "address": "京东APP-首页/玩一玩/我的-东东农场"
        },
        {
            "name": "东东工厂",
            "address": "京东APP-首页/玩一玩/我的-东东工厂"
        },
        {
            "name": "东东超市",
            "address": "京东APP-首页/玩一玩/我的-东东超市"
        },
        {
            "name": "领现金",
            "address": "京东APP-首页/玩一玩/我的-领现金"
        },
        {
            "name": "东东健康社区",
            "address": "京东APP-首页/玩一玩/我的-东东健康社区"
        },
        {
            "name": "京喜农场",
            "address": "京喜APP-我的-京喜农场"
        },
        {
            "name": "京喜牧场",
            "address": "京喜APP-我的-京喜牧场"
        },
        {
            "name": "京喜工厂",
            "address": "京喜APP-我的-京喜工厂"
        },
        {
            "name": "京喜财富岛",
            "address": "京喜APP-我的-京喜财富岛"
        },
        {
            "name": "京东极速版红包",
            "address": "京东极速版APP-我的-红包"
        }
    ],
    // 配置节点
    "nodeList": [
        {
            "client_url": "",//节点url
            "client_name": "腾讯云节点",// 节点名称
            "client_id": "", // 青龙应用id
            "client_secret": "",// 青龙应用secret
            "token": "",
            "expire": ""
        }
    ]
}
```
* app/config/config.default.js 中
```json
    const userConfig = {
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
```
*  配置文件
```
// add your user config here
const userConfig = {
    QL_URL: "", // 青龙访问地址 http://ip:port 或者直接域名
    QL_DIR: "/ql",
    ALLOW_NUM: 100, //节点最大提供cookie位置
    ALLOW_ADD: 1, //是否允许添加cookie
    NOTIFY: 0, //添加成功后,是否允许通知
    UA: "",
};
```
### 开发

```bash
$ npm i
$ npm run dev
```

### 部署

```bash
$ npm i
$ npm start
$ npm stop
```

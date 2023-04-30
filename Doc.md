# Nuxt3 Windows IISNode、Docker SSR 部署心得
###### tags: `Nuxt3` `SSR` `IISNode` `筆記`
## 前言
要在 Windows Server 部署 Nodejs 這個流程，

之前一直踩非常多的坑到最後的棄坑改用 Static Mode(Nuxt2 時期)

網路上的很多文章都是教學用 PM2 在 Windows 的部署

但因為還是比較熟悉 IIS 的操作，到了近期 Nuxt3 的推出，又重燃一次用 IISNode 部署的研究

最後，在卡了好幾天後有順利的做出，下面就對這個流程做一些說明

## 安裝
請依下面的順序安裝這幾個工具
1. [Nodejs](https://nodejs.org/en)
2. [IISNode Module](https://github.com/Azure/iisnode)
3. [URL Rewrite](https://iis-umbraco.azurewebsites.net/downloads/microsoft/url-rewrite)

## 坑的開始
我參考了網路非常多的文章 [will 保哥(next.js)](https://blog.miniasp.com/post/2023/03/26/How-to-deploy-Nextjs-to-Azure-Web-App-on-Windows)、[Leo(angular)](https://dotblogs.com.tw/Leo_CodeSpace/2020/07/24/172100)。

參考時做完之後會一直Nuxt3這個專案會跳出不支援 ES6 Module Import 的錯誤

針對這個問題在找了很久之後，查到有一個作者發佈一篇[處理流程](https://techcommunity.microsoft.com/t5/apps-on-azure-blog/supporting-es6-import-on-windows-app-service-node-js-iisnode/ba-p/3639037)

針對以上的參考文章，我整理一下覺得比較正確的流程


## IISNode部署流程
### Nuxt3 專案打包

```
npm run build

打包完成，會有訊息提示檔案輸出

Generated public .output/public
...略過
You can preview this build using node .output/server/index.mjs
```
需要部署到 IISNode 的檔案都會在 .output 資料夾內

### 新增 IISNode 應用程式集區
應用程式集區要跟 .net core 一樣選擇 "沒有受控程式碼"，讓應用程式交由 IISNode 託管

![](https://i.imgur.com/A15eu0d.png)


### 在 IIS 內新增站台
* 記得將資料夾新增 iis_iusrs 權限
* 應用程式集區要選擇剛剛新增的

![](https://i.imgur.com/iygbUZ9.png)


### 將 .output 資料夾複製到此站台的 folder 內
![](https://i.imgur.com/yakxgEI.png)

### 

### 設定處理常式對應

新增一支 server.js 檔案，讓這支 js 載入 SSR Server 的入口檔案
``` javascript
import("./.output/server/index.mjs");
```

並將 server.js 交給 IISNode 託管

``` web.config
<handlers>
    <!-- Indicates that the server.js file is a Node.js site to be handled by the iisnode module -->
    <add name="iisnode" path="server.js" verb="*" modules="iisnode" />
</handlers>
```

### 設定 URL Rewrite

將訪問到這站台的 Request，都交由 node.js 的 server.js 託管

==DynamicContent== 那一條 rule

``` web.config
<rewrite>
    <rules>
	<!-- Do not interfere with requests for node-inspector debugging -->
        <rule name="NodeInspector" enabled="false" patternSyntax="ECMAScript" stopProcessing="true">
            <match url="^index\/debug[\/]?" />
	</rule>

	<!-- First we consider whether the incoming URL matches a physical file in the /public folder -->
	<rule name="StaticContent">
	  <action type="Rewrite" url="public{REQUEST_URI}" />
	</rule>
  
	<!-- All other URLs are mapped to the Node.js site entry point -->
	<rule name="DynamicContent">
	  <conditions>
	    <add input="{REQUEST_FILENAME}" matchType="IsFile" negate="True" />
	  </conditions>
	  <action type="Rewrite" url="server.js" />
	</rule>
    </rules>
</rewrite>
```

這樣的部署方式就不需要改動 .output 的任何檔案，經過我的測試也適用 angular 的 SSR 模式

這邊附上我實作這個流程的 [Source Code](https://github.com/chinggo/IISNode-Nuxt3SSR)


### 容器部署
docker 的使用目前越來越盛行，裡面也一併做了相關的設定檔

可以參考 dockerfile、ecosystem.config.js(PM2執行設定檔)


### 相關連結
* [IISNode 不支援 ES6 Module Import](https://techcommunity.microsoft.com/t5/apps-on-azure-blog/supporting-es6-import-on-windows-app-service-node-js-iisnode/ba-p/3639037)
* [next.js SSR 部署](https://blog.miniasp.com/post/2023/03/26/How-to-deploy-Nextjs-to-Azure-Web-App-on-Windows)
* [angular SSR 部署](https://dotblogs.com.tw/Leo_CodeSpace/2020/07/24/172100)
* [Nux3 部署 Git Source](https://github.com/chinggo/IISNode-Nuxt3SSR)







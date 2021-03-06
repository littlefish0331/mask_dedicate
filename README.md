# README

**尚未處理的問題:**

- 資料儲存到公司本機資料庫
- 爬取 [健康保險資料開放服務 - 口罩響應人道援助之前1日同意援助明細清單](https://data.nhi.gov.tw/Datasets/DatasetDetail.aspx?id=661&Mid=SHEILA)
- 網站建立

## 緣由

- [口罩開放捐 女怡君.男俊宏捐最多 - Yahoo奇摩新聞](https://tw.news.yahoo.com/%E5%8F%A3%E7%BD%A9%E9%96%8B%E6%94%BE%E6%8D%90-%E5%A5%B3%E6%80%A1%E5%90%9B-%E7%94%B7%E4%BF%8A%E5%AE%8F%E6%8D%90%E6%9C%80%E5%A4%9A-120300578.html)
- [健康保險資料開放服務 - 口罩響應人道援助之前1日同意援助明細清單](https://data.nhi.gov.tw/Datasets/DatasetDetail.aspx?id=661&Mid=SHEILA)
- [TaiwanCanHelp - 響應口罩世界互助](https://taiwancanhelp.com.tw/mask-dedicate)

先是看到 yahoo 新聞說，透過男女生菜市場名字，統計誰捐的最多。  
所以我就好奇這個資料是怎麼取得的，難道記者一個一個加嗎!?
進一步找尋開放資料，發現只有這個資料集「口罩響應人道援助之前1日同意援助明細清單」，  
所以除非有持續爬取累積，不然沒辦法統計阿!!

後來我想不太可能(台灣記者很厲害，但是有這麼勤勞嗎!?)  
所以我就去可以查詢的網頁下方試著使用，
網頁的功能很像是資料庫query的方式，輸入名字或是日期，輸出時間、名字、數量

所以看一下網頁原始碼，發現了這個資料庫的API，恩~方法不難。  
因此我決定來試著每天排程爬取整理看看，  
假如有哪一天API不能query了，再從開放資料的地方固定爬取做更新這樣。

下來之後，可以統計看看不同名字捐口罩的數量，以及捐贈趨勢變化。

## 目標

資料目前一天更新一次，爬取下列網址

- [https://taiwancanhelp.com.tw/mask-dedicate](https://taiwancanhelp.com.tw/mask-dedicate)
  - [https://taiwancanhelp.com.tw/api/mask?name=雅婷&show=200](https://taiwancanhelp.com.tw/api/mask?name=雅婷&show=200)
  - [https://taiwancanhelp.com.tw/api/mask?date=2020/04/29&show=1000](https://taiwancanhelp.com.tw/api/mask?date=2020/04/29&show=1000)
- [健康保險資料開放服務 - 口罩響應人道援助之前1日同意援助明細清單](https://data.nhi.gov.tw/Datasets/DatasetDetail.aspx?id=661&Mid=SHEILA)

- 資料儲存公司本機
  - 每日的紀錄，檔名為日期
  - 每日的summary，放在 dailysummary.csv
- 資料儲存到公司本機資料庫

## 資料觀察

- 資料每日更新時間約為 11:00 am (UTC+8)，統計截至前一日 23:59 前登錄的資料。所以今天最多只能爬到昨天為止的資料。
- 格式json
- mask_dedicate_detail.csv 欄位 [_id, date, name, count,_created]→[_id, date, name, count]
  - _id: 為每次捐贈的流水號，即使同一個人也不會依樣，就是一直編號下去。(十六進位)
  - name: 缺失就為 Anonymous
  - _created: 是每天資料庫更新時間，並非捐贈的時間，所以刪去。
- mask_dedicate_dailysummary.csv 欄位 [date, total_masks, total_dedicators]

## 步驟

- 爬取 json 資料
- 開始時間2020/04/27
- 每次1000筆
- 資料整理
- 休息0.5秒
- 爬取下一頁直到結束。沒有下一頁的話，吐回的結果會直接少掉 next, next_api 這些節點。is.null(response$data$next_api)
- 最後結束時，抓取 daily summary
- 整理存檔
- 下一天。之後改排程為每天中午1200執行。
  - 因為有 daily summary，所以只要去隊已經爬過的時間，就可以知道還有哪些日期要爬取。

## 網站設計

網站名稱: 口罩捐贈分析，中英版本。  

:heavy_exclamation_mark:**資料最小單位:每日。**

- 目的: 簡單的查詢功能以及統計趨勢顯示
- 分析注意概念: 人次而非人數，是因為可能user可捐贈的額度是12個口罩，早上心血來潮捐三個，晚上看完新聞覺得別的國家很需要，所以再捐2個。但是這在紀錄上會是兩筆，且無法判斷是同一個人，故使用人次一詞。

### 預計分析圖表

**dashboard:**

- 折線圖: 統計口罩捐贈總數，[x, y] = [timestamp, mask_number]
- 折線圖: 統計口罩捐贈總人次
  - 是否去除0個
  - [x, y] = [timestamp, people_number]
- 折線圖: 平均每人次捐贈個數
- 類似K線圖: 開盤是昨日的數量，收盤是今日數量，沒有最高最低點，紅色漲，綠色跌。
- heat calender: 日曆熱度圖
  - 統計口罩捐贈總數
  - 統計口罩捐贈總人次

**search panel:**

- 查詢功能: 支持正規表示法
  - 查詢時間範圍
  - 搜尋姓氏。
  - 搜尋文字: 即姓名中有該字就拉出來。(整個name都考慮)
  - 輸出姓名、口罩數。
  - 輸出符合條件筆數。(即為人次)

**statistics panel:**

- 可以限制時間範圍
- 統計 相同姓名下，捐贈口罩數排行榜
  - 是否隱藏 anonymous
  - 姓名
  - 口罩總數
- 統計 相同姓氏下，捐贈口罩數排行榜
  - 是否隱藏 anonymous
  - 姓氏
  - 口罩總數
- 文字雲
  - 姓氏
  - 姓名
- 單筆捐贈口罩個數排行榜:
  - 前100名
  - 以時間排序，顯示日期
  - 顯示名字
- 捐贈口罩總數
- 捐贈人次總數
- 捐贈個數之人次統計: 個數*人次=捐贈口罩總數，人次加總=捐贈人次總數。

## 技術學習

- query show 的筆數可以自動調整，但基本上不會抓太大。先設定每次1000筆。
- 學習接續使用 &next 的參數，直到爬取結束。
- 紀錄有哪些天的資料已經爬過了，以方便後續爬取的篩選。

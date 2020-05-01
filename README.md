# README

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

## 目標

資料目前一天更新一次，爬取下列網址

- [https://taiwancanhelp.com.tw/mask-dedicate](https://taiwancanhelp.com.tw/mask-dedicate)
  - [https://taiwancanhelp.com.tw/api/mask?name=雅婷&show=200](https://taiwancanhelp.com.tw/api/mask?name=雅婷&show=200)
  - [https://taiwancanhelp.com.tw/api/mask?date=2020/04/29&show=1000](https://taiwancanhelp.com.tw/api/mask?date=2020/04/29&show=1000)
- [健康保險資料開放服務 - 口罩響應人道援助之前1日同意援助明細清單](https://data.nhi.gov.tw/Datasets/DatasetDetail.aspx?id=661&Mid=SHEILA)

- 資料儲存公司本機，檔名為日期
- 資料儲存到公司本機資料庫

## 資料觀察

- 每日更新，時間大約是凌晨，所以今天最多只能爬到昨天的資料
- 格式json
- mask_dedicate_detail.csv 欄位 [pid, date, name, count, created]→[pid, date, name, count]
  - pid: 為每次捐贈的流水號，即使同一個人也不會依樣，就是一直編號下去。(十六進位)
  - name: 缺失就為 Anonymous
  - created: 是每天資料庫更新時間。
- mask_dedicate_dailysummary.csv 欄位 [date, total_masks, total_dedicators]

## 技術學習

- query show 的筆數可以自動調整，但基本上不會抓太大。先設定每次1000筆。
- 學習接續使用 &next 的參數，直到爬取結束。

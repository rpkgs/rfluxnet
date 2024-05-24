# rfluxnet

- [ ] 能量闭合检查

- [ ] 净辐射计算方法测试，测试能否移除MODIS的Emiss和Albedo

## 数据组成

> 以FLUXNET2015为主（212-4），补充了nesdc（40）, He2022（14）, plumber2（49），共计311个站点。

`FLUXNET2015`中移除了4个长度较短的通量站（`c("CN-Cha", "CN-Dan", "CN-Din", "CN-Qia")`），采用`ChinaFlux`中最新的数据进行了替换。

```r
  source          N  
  <chr>       <int>  
1 nesdc          40  
2 He2022         14  
3 fluxnet2015   208  
4 plumber2       49 
```

站点信息见：[data/st_flux311.rda](data/st_flux311.rda)

```r
r$> st_flux311
[data.table]: 
# A data frame: 311 × 6
   site       name       lon   lat IGBP  source
   <chr>      <chr>    <dbl> <dbl> <chr> <chr> 
 1 LuanCheng  栾城      115.  37.9 CRO   nesdc 
 2 LinZe      临泽      100.  39.3 CRO   nesdc 
 3 YuCheng    禹城      117.  36.8 CRO   nesdc 
 4 GuCheng    固城      116.  39.1 CRO   nesdc 
 5 JinZhou    锦州      121.  41.1 CRO   nesdc 
 6 JuRong     句容      119.  31.8 CRO   nesdc 
 7 PanJin-CRO 盘锦-CRO  122.  40.9 CRO   nesdc 
 8 QingYang   庆阳      108.  35.7 CRO   nesdc 
 9 ChangLing  长岭      123.  44.6 CRO   nesdc 
10 MiYun      密云      117.  40.6 CRO   He2022
```

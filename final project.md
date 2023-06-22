## 네이버 주식 웹스크랩핑과 업종별 분석.
- R language를 이용해 네이버 증권 홈페이지를 웹스크랩핑한다.
- rvest와 Rselenium 패키지를 이용한다.

### 네이버 금융 업종별 종목 수집
 1. [네이버 증권 업종별 시세](https://finance.naver.com/sise/sise_group.naver?type=upjong)에서 업종명 ULR을 추출한다.

<details>
  <summary>접기/펼치기</summary>
  
```r
#업종별 종목 주소
url <- "https://finance.naver.com/sise/sise_group.naver?type=upjong"
html <- read_html(url,encoding = "EUC-KR")

sise_gr <- html %>%
  html_nodes("table") %>%
  html_nodes("td") %>%
  html_nodes("a") %>%
  html_attr("href") %>%
  .[1:79]

sise1_gr <- paste0("https://finance.naver.com", sise_gr)
```
</details>
  
  2. [업종별 개별 주식 ex.교육서비스](https://finance.naver.com/sise/sise_group_detail.naver?type=upjong&no=290)에서 내가 원하는 체크박스를 선택한다.
     - 네이버의 체크박스(거래량, 매수호가, 거래대금 등)를 선택하는 것은 동적 웹스크랩핑이므로 Rselenium을 이용해야 한다.
     - 최대 6개밖에 선택할 수 없어 더 많은 항목을 선택하고 싶으면 다수의 table을 만들어 merge할 수 있다.
       
  ** 거래대금, 자산총계, 부채총계, 영업이익, 영업이익증가율, 외국인비율 테이블 만들기 **
  <details> 
  <summary>접기/펼치기</summary>
  
```r
# 거래대금, 자산총계, 부채총계, 영업이익, 영업이익증가율, 외국인비율 테이블 만들기
table1 <- c()
for (k in 1:length(sise1_gr)) {
  remDr$navigate(sise1_gr[k])
  # remDr$ screenshot (display = TRUE)
  
  
  # checked 속성이 있는 요소를 찾기 위한 XPath
  xpath <- '//input[@type="checkbox" and @checked]'
  
  # 요소 선택
  elements <- remDr$findElements(using = "xpath", value = xpath)
  
  # 선택된 요소의 checked 속성 제거
  for (element in elements) {
    remDr$executeScript("arguments[0].removeAttribute('checked')",
                        list(element))
  }
  
  # remDr$ screenshot (display = TRUE)
  
  
  for (i in c(3, 5, 10, 11, 15, 16)) {
    element_id <- paste0("option", i)
    checkbox <-
      remDr$findElement(
        using = "xpath",
        value = sprintf('//input[@type="checkbox" and @id="%s"]', element_id)
      )
    checkbox$clickElement()
  }
  
  # remDr$screenshot(display = TRUE)
  
  
  element <-
    remDr$findElement(using = "xpath", value = "/html/body/div[3]/div[2]/div[2]/div[3]/form/div/div/div/a[1]")
  
  
  if (!is.null(element)) {
    # 클릭
    element$clickElement()
  } else {
    # 요소가 없을 경우 처리
  }
  
  remDr$screenshot(display = TRUE)
  
  table_element <-
    remDr$findElement(using = "css", value = "#contentarea > div:nth-child(5) > table")
  
  table_html <- table_element$getPageSource()[[1]]
  
  # Extract the table data using CSS selector
  table_data <-
    read_html(table_html) %>%
    html_nodes("#contentarea > div:nth-child(5) > table") %>%
    html_table(fill = TRUE) %>%
    as.data.frame() %>%
    select(-토론실) %>%
    select(-Var.12)
  
  jong_mok <- read_html(table_html) %>%
    html_nodes("table") %>%
    html_nodes("td") %>%
    html_text() %>%
    .[2] %>%
    gsub("\\n|\\t", "", .)
  
  업종명 <-  matrix(jong_mok , nrow(table_data))
  
  df <- cbind(업종명, table_data)
  
  table1 <- rbind(table1, df)
  
}

# View(table1)

sise1_gr <- paste0("https://finance.naver.com", sise_gr)
```
</details>

** 매출액, 영업이익, 당기순이익, 주당순이익, 매출액증가율, 유보율 테이블 만들기 **

<details>

 <summary>접기/펼치기</summary>

```r
# table2 <- c()
for (k in 1:length(sise1_gr)) {
  remDr$navigate(sise1_gr[k])
  # remDr$ screenshot (display = TRUE)
  
  
  # checked 속성이 있는 요소를 찾기 위한 XPath
  xpath <- '//input[@type="checkbox" and @checked]'
  
  # 요소 선택
  elements <- remDr$findElements(using = "xpath", value = xpath)
  
  # 선택된 요소의 checked 속성 제거
  for (element in elements) {
    remDr$executeScript("arguments[0].removeAttribute('checked')",
                        list(element))
  }
  
  # remDr$ screenshot (display = TRUE)
  
  
  for (i in c(5, 17, 22, 23, 25, 27)) {
    element_id <- paste0("option", i)
    checkbox <-
      remDr$findElement(
        using = "xpath",
        value = sprintf('//input[@type="checkbox" and @id="%s"]', element_id)
      )
    checkbox$clickElement()
  }
  
  # remDr$screenshot(display = TRUE)
  
  
  element <-
    remDr$findElement(using = "xpath", value = "/html/body/div[3]/div[2]/div[2]/div[3]/form/div/div/div/a[1]")
  
  #
  if (!is.null(element)) {
    # 클릭
    element$clickElement()
  } else {
    # 요소가 없을 경우 처리
  }
  
  remDr$screenshot(display = TRUE)
  
  table_element <-
    remDr$findElement(using = "css", value = "#contentarea > div:nth-child(5) > table")
  
  
  table_html <- table_element$getPageSource()[[1]]
  
  # Extract the table data using CSS selector
  table_data <-
    read_html(table_html) %>%
    html_nodes("#contentarea > div:nth-child(5) > table") %>%
    html_table(fill = TRUE) %>%
    as.data.frame() %>%
    select(-토론실) %>%
    select(-Var.12)
  
  jong_mok <- read_html(table_html) %>%
    html_nodes("table") %>%
    html_nodes("td") %>%
    html_text() %>%
    .[2] %>%
    gsub("\\n|\\t", "", .)
  
  업종명 <-  matrix(jong_mok , nrow(table_data))
  
  df <- cbind(업종명, table_data)
  
  table2 <- rbind(table2, df)
  
}

# View(table2)
```
</details>

  3. 데이터에는 결측값이 포함된 정보외에 ETF, ETN 상품들도 포함하고 있어 전처리가 필요하다.
     - ETF(ETF는 주식이나 채권 등 다양한 자산에 투자하여 인덱스 또는 특정 시장 섹터의 성과를 추적하는 투자 상품)
     - ETN(ETN은 채권이나 파생상품과 같은 특정 자산에 연결된 증권상품으로, 주로 특정 지수나 자산의 가치 또는 수익률을 추적)
     - ETN은 채권 상품이나 ETF는 투자포트폴리오를 지니고 있는 투자회사로 투자자들은 ETF주식을 소유하고 해당 포트폴리오의 가치에 따라 이익을 얻게됨
     - ETN은 발생자의 신용위험에 노출되고 ETN의 가치는 발행자의 양속에 따라 결정된다. 따라서 발행자가 부도를 선언하면 투자자는 그 가치를 상실한다. 그러나 ETF는 포트폴리오 자산의 가치에 직접 노출되므로 발행자의 신용위험에 덜 노출된다.

<details>
  <summary>접기/펼치기</summary>

  ```r
table1_ad <- table1 %>%
  .[, c(1, 2, 6:11)] %>%
  filter(!영업이익 %in% c("", NA))

table_j <-
  as.data.frame(lapply(table1_ad, function(x)
    gsub(",", "", x))) # ,를 지우지 않으면 숫자로 인식을 못함.
```
</details>

### 종목별 데이터 시각화

#### 1. 영업이익 변수의 밀도 그래프
   > 완벽한 대칭은 아니지만 평균을 중심으로 대칭성을 보임
<details>
 <summary>접기/펼치기</summary>
 
```r
ggplot(data = table_j, aes(x = 영업이익)) +
  geom_density(fill = "steelblue", color = "black") +
  labs(x = "영업이익", y = "밀도", title = "영업이익 분포") +
  theme_minimal() +
  xlim(-1000, 1000)

```
</details>

<p align="center">
  <img src="https://github.com/baedabean/myrepo/blob/main/%EC%8A%A4%ED%81%AC%EB%A6%B0%EC%83%B7%202023-06-12%20%EC%98%A4%EC%A0%84%209.50.42.png?raw=true)https://github.com/baedabean/myrepo/blob/main/%EC%8A%A4%ED%81%AC%EB%A6%B0%EC%83%B7%202023-06-12%20%EC%98%A4%EC%A0%84%209.50.42.png?raw=true">
</p>

 - 영업이익(EBIT:Earning before interest and taxes)은 매출총익에서 판매관리비를 뺀 것이다. 기업이 경영하는 주된 사업의 수익성을 나타낸다. 즉, 영업활동을 통해 순수하게 남은 이익을 말한다.
 - 영업이익 = 매출액-매출원가-판매관리비
 - 판매관리비는 상품의 판매활동비나 기업의 유지 관리를 위해 지출된 비용을 말하며 인건비와 세금, 인건비와 세금, 공과금, 감가상각비, 광고비 등이 있다.

#### 2. 매출액 변수의 밀도 그래프
   > 오른쪽으로 긴꼬리를 지는 분포의 형태를 보임

<details>
   
 <summary>접기/펼치기</summary>
 
```r
# 매출액 변수의 밀도 그래프
ggplot(data = table_j, aes(x =매출액)) +
  geom_density(fill = "steelblue", color = "black") +
  labs(x = "매출액", y = "밀도", title = "매출액 분포") +
  theme_minimal() +
  xlim(0, 5000)
```
</details>

<p align="center">
  <img src="https://github.com/baedabean/myrepo/blob/main/%EC%8A%A4%ED%81%AC%EB%A6%B0%EC%83%B7%202023-06-12%20%EC%98%A4%EC%A0%84%209.50.53.png?raw=true">
</p>

- 매출액은 기업의 주된 영업활동에서 발생한 제품, 상품, 용역 등의 총매출액에서 매출할인, 매출환입, 매출에누리 등을 차감한 금액이다.

#### 3. 그룹별 매출액 평균
   > 매출액 평균 상위 30개의 기업만 관찰한다.

<details>
   
 <summary>접기/펼치기</summary>
 
```r
#그룹별 매출액 평균

group_30 <- table_j %>%
  group_by(업종명) %>%
  summarize(mean_매출액 = mean(매출액, na.rm = TRUE)) %>% 
  top_n(30, mean_매출) 

#막대그래프 그리기

ggplot(data = group_30 , aes(x = 업종명, y = mean_매출액, fill = 업종명)) +
  stat_summary(fun = "mean",
               geom = "bar",
              position = "dodge") +
  labs(x = "업종명", y = "매출액", title = "그룹별 매출액 평균") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
```
</details>

<p align="center">
  <img src="https://github.com/baedabean/myrepo/blob/main/%EA%B7%B8%EB%A3%B9%EB%B3%84%20%EB%A7%A4%EC%B6%9C%EC%95%A1%20%ED%8F%89%EA%B7%A0.png?raw=true">
</p>

 - 그룹별 매출액 평균을 봤을 때 가장 높은 매출을 기록하고 있는 업종은 **자동차**임을 확인할 수 있다.
 - 생명보험의 매출액도 높은 수준으로 관찰되고 그 뒤에 은행과 복합기업순으로 매출액 평균을 기록할 수 있다.
   
#### 4. 그룹별 매출액 증가율
   > 매출액 증가율의 상위 30개의 기업만 관찰한다.

<details>
   
 <summary>접기/펼치기</summary>
 
```r
#그룹별 매출액 증가율
top_30_f <- table_j %>%
  group_by(업종명) %>%
  summarize(mean_매출액증가율 = mean(매출액증가율, na.rm = TRUE)) %>% 
  top_n(30, mean_매출액증가율) 

#막대그래프 그리기
ggplot(data = top_30 , aes(x = 업종명, y = mean_매출액증가율, fill = 업종명)) +
  stat_summary(fun = "mean",
               geom = "bar",
               position = "dodge") +
  labs(x = "업종명", y = "매출액 증가율", title = "그룹별 매출액 증가율") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
```
</details>

<p align="center">
  <img src="https://github.com/baedabean/myrepo/blob/main/%EA%B7%B8%EB%A3%B9%EB%B3%84%20%EB%A7%A4%EC%B6%9C%EC%95%A1%20%EC%A6%9D%EA%B0%80%EC%9C%A8.png?raw=true">
</p>

- 그룹별 매출액 증가율을 봤을 때 **항공사**와 **호텔,레스토랑,레져**산업 매출액이 100% 넘게 증가했다.
- 이는 코로나19의 영향으로 위축되었던 산업이 펜데믹으로 들어서면서 위 산업이 회복세를 보이고 있음을 확인 할 수 있다.
- 다른 항목에 비해 **자동차**산업의 성장률이 두드러져 보이진 않지만 **자동차**산업의 매출액 증가율은 약 24%로 높은 수준을 보이고 있다.
- **무역회사와 판매업체**역시 24%를 상회하는 매출액 증가율을 보이고 있다.
- 매출액 증가율로 짐작할 수 있는 사실은 코로나 19의 영향력에서 벗어나면서 반도체, 천연자원 등의 산업이 회복하고 있음을 볼 수 있다.

#### 5. 매출액과 영업이익 산점도/영업이익 상자그림

   > Q.그렇다면 매출액 혹은 매출액 증가율이 영업이익으로 질까?
   >> A. 일반적으로 그렇다고 할 수 있지만 반드시 그런 것은 아니다.
   
  <details>
   
 <summary>접기/펼치기</summary>
 
```
#매출액 상위30개를 기준으로 영업이익률 table 작성

top_m_n <- top_30$업종명
top_m <- c()
for (i in 1:30) {
 top_m_table <-  table_j %>% 
    filter(업종명%in% top_m_n[i])
 top_m <- rbind(top_m, top_m_table)
}

#스캐터 플롯 그리기 
ggplot(data = table_j, aes(x = 매출액, y = 영업이익, color = 업종명)) +
 geom_point() +
 labs(x = "매출액", y = "영업이익", title = "매출액과 영업이익 관계") +
 geom_smooth(method = "lm", se=F) ## 그룹별 회귀선 추가

#상자그림 그리기
ggplot(data =  top_m, aes(x = 업종명, y = 영업이익, fill = 업종명)) +
  geom_boxplot() +
  labs(x = "업종명", y = "영업이익", title = "그룹별 매출액 비교") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  ylim(-1500, 1500)
```
</details>

<p align="center">
  <img src="https://github.com/baedabean/myrepo/blob/main/%E1%84%86%E1%85%A2%E1%84%8E%E1%85%AE%E1%86%AF%E1%84%8B%E1%85%A2%E1%86%A8%E1%84%80%E1%85%AA%20%E1%84%8B%E1%85%A7%E1%86%BC%E1%84%8B%E1%85%A5%E1%86%B8%E1%84%8B%E1%85%B5%E1%84%8B%E1%85%B5%E1%86%A8%E1%84%85%E1%85%B2%E1%86%AF%20%E1%84%89%E1%85%A1%E1%86%AB%E1%84%8C%E1%85%A5%E1%86%B7%E1%84%83%E1%85%A9%20%E1%84%87%E1%85%A9%E1%86%A8%E1%84%89%E1%85%A1%E1%84%87%E1%85%A9%E1%86%AB.png?raw=true">
</p>

- 위 그림에서 알 수 있듯이 매출액이 증가하면 영업이익이 증가하는 방향성을 확인 할 수 있지만 엽종별로 분류해서 보면 **반듯이 매출액이 영업이익으로 연결되는 것은 아님**을 알 수있다.
- 매출액 증가액이 영업이익으로 이어질때 업종별로 영향력에 차이가 있음을 확인 할 수 있다.

<p align="center">
  <img src="https://github.com/baedabean/myrepo/blob/main/%E1%84%80%E1%85%B3%E1%84%85%E1%85%AE%E1%86%B8%E1%84%87%E1%85%A7%E1%86%AF%20%E1%84%8B%E1%85%A7%E1%86%BC%E1%84%8B%E1%85%A5%E1%86%B8%E1%84%8B%E1%85%B5%E1%84%8B%E1%85%B5%E1%86%A8.png?raw=true">
</p>

- 높은 매출액을 기록했던 **자동차**산업의 영업이익은 오히려 적자임을 확인할 수 있다.
- 매출액과 매출액 증가율이 영업이익에 긍적적으로 영향을 준 산업은 **무역회사와판매업채**임을 확인 할 수 있다.

#### 6. 영업이익 증가율 상자그림
<details>
   
 <summary>접기/펼치기</summary>
 
```
#상자그림 그리기
ggplot(data = top_m, aes(x = 업종명, y = 영업이익증가율, fill = 업종명)) +
  geom_boxplot() +
  labs(x = "업종명", y = "영업이익증가율", title = "업종별 영업이익증가율 상자그림")+
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+
  ylim(-200,200)
```
</details>

<p align="center">
  <img src="">
</p>


#### 6. 그룹별 외국인 평균
   
<details>
   
 <summary>접기/펼치기</summary>
 
```
# 그룹별 외국인 평균
top_30_f <- table_j %>%
  group_by(업종명) %>%
  summarize(mean_외국인비율 = mean(외국인비율, na.rm = TRUE)) %>% 
  top_n(30, mean_외국인비율)

#막대그래프 그리기
ggplot(data = top_30_f , aes(x = 업종명, y = mean_외국인비율, fill = 업종명)) +
  stat_summary(fun = "mean",
               geom = "bar",
               position = "dodge") +
  labs(x = "업종명", y = "외국인 비율", title = "그룹별 외국인 비율") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

```
</details>


<p align="center">
  <img src="https://github.com/baedabean/myrepo/blob/main/%EA%B7%B8%EB%A3%B9%EB%B3%84%20%EC%99%B8%EA%B5%AD%EC%9D%B8%20%EB%B9%84%EC%9C%A8.png?raw=true">
</p>

- 외국인 비율은 **자동차**분야가 약 26%로 높은 비율 관계를 보여줬다.
- **은행** 역시 높은 외국인 비율을 가지고 있어, 담배를 제외한다면 외국인 비율이 1등인 산업이다.
- 가장 높은 외국인 비율을 44%인 담배인데, 담배는 기업이 독점적으로 운영해 1개의 기업만 존재한다.

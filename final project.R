# install.packages("RSelenium")
# library(RSelenium)
# library(rvest)
# library(tidyverse)

# Selenium WebDriver 시작
remDr <-
  remoteDriver(remoteServerAddr = 'localhost',
               port = 4444 ,
               browserName = "chrome")
remDr$open()
remDr$close()

remDr$getStatus()

# 업종별 종목 주소
# url <- "https://finance.naver.com/sise/sise_group.naver?type=upjong"
# html <- read_html(url,encoding = "EUC-KR")
#
# sise_gr <- html %>%
#   html_nodes("table") %>%
#   html_nodes("td") %>%
#   html_nodes("a") %>%
#   html_attr("href") %>%
#   .[1:79]
#
# sise1_gr <- paste0("https://finance.naver.com", sise_gr)

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

# 매출액, 영업이익, 당기순이익, 주당순이익, 매출액증가율, 유보율 테이블 만들기
table2 <- c()
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

table1_ad <- table1 %>%
  .[, c(1, 2, 6:11)] %>%
  filter(!영업이익 %in% c("", NA))

table2_ad <- table2 %>%
  .[, c(1, 2, 6:11)] %>%
  filter(!영업이익 %in% c("", NA))

nrow(table1_ad)
nrow(table2_ad)
nrow(table_j)


table_j <-
  left_join(table1_ad, table2_ad, by = c("업종명", "종목명", "영업이익"))
table_j <-
  as.data.frame(lapply(table_j, function(x)
    gsub(",", "", x))) # ,를 지우지 않으면 숫자로 인식을 못함.

table_j <-
  cbind(table_j[, c(1, 2)], as.data.frame(lapply(table_j[, c(3:13)], as.numeric)))


table_j <- mutate(table_j, 부채비율 = 부채총계 / 자산총계)


#library(ggplot2)
ggplot(data = table_j, aes(x = 업종명, y = 영업이익, fill = 업종명)) +
  geom_boxplot() +
  labs(x = "업종명", y = "영업이익", title = "그룹별 매출액 비교") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  ylim(-1500, 1500)


table_j_filtered <- table_j %>%
  drop_na(매출액, 영업이익)

# 스캐터 플롯을 그립니다
#ggplot(data = table_j, aes(x = 매출액, y = 영업이익, color = 업종명)) +
#  geom_point() +
#  labs(x = "매출액", y = "영업이익", title = "매출액과 영업이익 관계") +
#  ylim(-2000,2000)+
#  xlim(0,5000)

ggplot(data = table_j, aes(x = 업종명, y = 매출액, fill = 업종명)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(x = "업종명", y = "매출액", title = "업종별 매출액 비교") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

sd <- table_j %>%
  group_by(업종명) %>%
  summarise(영업이익_표준편차 = sd(영업이익, na.rm = TRUE))

# 시각화 - 막대 그래프
ggplot(data = sd , aes(x = 업종명, y = 영업이익_표준편차, fill = 업종명)) +
  geom_bar(stat = "identity") +
  labs(x = "업종명", y = "영업이익 표준편차", title = "업종별 영업이익 표준편차") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# 매출액 변수의 밀도 그래프
ggplot(data = table_j, aes(x = 매출액)) +
  geom_density(fill = "steelblue", color = "black") +
  labs(x = "매출액", y = "밀도", title = "매출액 분포") +
  theme_minimal() +
  xlim(0, 5000)

# 영업이익 변수의 밀도 그래프
ggplot(data = table_j, aes(x = 영업이익)) +
  geom_density(fill = "steelblue", color = "black") +
  labs(x = "영업이익", y = "밀도", title = "영업이익 분포") +
  theme_minimal() +
  xlim(-1000, 1000)

# 매출액 변수의 상자그림
ggplot(data = table_j, aes(x = 업종명, y = 매출액)) +
  geom_boxplot(fill = "steelblue", color = "black") +
  geom_density(alpha = 0.5) +
  labs(x = "업종명", y = "매출액", title = "매출액 분포 비교") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  ylim(0, 5000)

# 그룹별 매출액 평균과 표준편차
ggplot(data = table_j, aes(x = 업종명, y = 매출액, fill = 업종명)) +
  stat_summary(fun = "mean",
               geom = "bar",
               position = "dodge") +
  stat_summary(
    fun = "mean",
    aes(label = round(..y.., 2)),
    position = position_dodge(width = 0.9),
    vjust = -0.5
  ) +
  stat_summary(
    fun.data = "mean_sdl",
    geom = "errorbar",
    width = 0.2,
    position = position_dodge(width = 0.9)
  ) +
  labs(x = "업종명", y = "매출액", title = "그룹별 매출액 평균과 표준편차") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# 매출액증가율과 유보율 관계
ggplot(data = table_j, aes(x = 업종명, y = 매출액증가율, fill = 유보율)) +
  geom_boxplot() +
  labs(x = "업종명",
       y = "매출액증가율",
       fill = "유보율",
       title = "매출액증가율과 유보율 관계") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  ylim(0, 1000)

###########################################################################################################################
#필요패키지 불러오기 
library(RSelenium)
library(rvest)
library(lubridate)
library(telegram.bot)
library(tidyverse)
library(taskscheduleR)
###########################################################################################################################
#스케쥴러 설정
setwd("C:/")
telegram.schedule = file.path('C:/final_code.R')

#10초 뒤 실행 24시간 마다 재실행
taskscheduler_create(taskname = 'send_telegram', rscript = telegram.schedule,
                     schedule = 'HOUR',
                     starttime = format(Sys.time() + 10, '%H:%M'),
                     startdate = format(Sys.time(), '%Y/%m/%d'),
                     modifier = 24)
###########################################################################################################################
#텔레그램 봇설정 
bot = Bot(token = '####') #api token 부분 ####에 본인봇의 토큰입력
print(bot$getMe())
updates = bot$getUpdates()
updates[[1]]$message$chat
chat_id = updates[[1]]$message$chat$id
###########################################################################################################################
#selenium 포트설정
remDr <- remoteDriver(
  remoteServerAddr = "localhost",
  port = 4446L,
  browserName = "chrome"
)
#java -Dwebdriver.gecko.driver="geckodriver.exe" -jar selenium-server-standalone-3.9.1.jar -port 4446
###########################################################################################################################
#소스코드 데이터 저장 폴더 파일생성
folder <- 'C:/githubdata/saved_data'
if(!dir.exists(folder)) dir.create(folder)
Sys.sleep(2)
setwd(folder)
date <- Sys.Date()
h <- hour(Sys.time()) 
m <- minute(Sys.time())
now <- paste(date, h, m, sep='-')
now.folder <- paste(folder, now, sep='/')
if(!dir.exists(now.folder)) dir.create(now.folder)
Sys.sleep(2)
setwd(now.folder)  

c_url='http://www.cgv.co.kr/movies/?lt=1&ft=1' #cgv url
m_url='http://www.megabox.co.kr/?menuId=movie-showing' #megabox url
l_url='http://www.lottecinema.co.kr/LCHS/Contents/Movie/Movie-List.aspx' #lottecinema url
file.name <- c(paste0("cgv", '.txt'),paste0("lotte", '.txt'),paste0("mega", '.txt'))
file1 <- read_html(c_url)
file2 <- read_html(l_url)
file3 <- read_html(m_url)
write_xml(file1, file = file.name[1])
Sys.sleep(2)
write_xml(file2, file = file.name[2])
Sys.sleep(2)
write_xml(file3, file = file.name[3])
Sys.sleep(2)
###########################################################################################################################
remDr$open()
Sys.sleep(3)
remDr$navigate(c_url) #cgv 홈페이지 접속
Sys.sleep(2)
btn1 <- remDr$findElement(using="xpath", value='//*[@id="contents"]/div[1]/div[3]/button')
btn1$clickElement() #더보기 버튼클릭
Sys.sleep(2)
c_title <- c()
c_title <- remDr$findElements(using = "css", '.title')
c_title <- unlist(lapply(c_title, function(x) {x$getElementText()}))
c_title <- c_title[1:25] #영화 제목 저장
c_title <- gsub("\\[", "", c_title) #title 데이터 클리닝
c_title <- gsub("\\]", "", c_title)
c_title <- gsub(":", "", c_title)
c_title <- gsub("-", "", c_title)

c_temp <- remDr$findElements(using = "css", '.percent')
c_temp <- unlist(lapply(c_temp, function(x) {x$getElementText()})) #예매율과 평점 데이터
#예매율과 평점 분리
c_score <- c()
c_adv <- c()
c_adv[1] <- c_temp[1]
for(i in 2:length(c_temp)){
  if(i%%2==1){
    c_adv[i] <- c_temp[i]
  }else if(i%%2==0){
    c_score[i] <- c_temp[i]
  }
}
c_adv <- na.omit(c_adv)
c_score <- na.omit(c_score) #?는 실제로 홈페이지 평점이 ?로 존재
c_adv <- c_adv[1:25] #예매율 데이터 저장 
c_adv <- gsub("예매율", "", c_adv) #데이터 클리닝 
c_adv <- gsub("%", "", c_adv)
c_adv <- as.numeric(c_adv)
c_score <- c_score[1:25] #평점 데이터 저장 
c_score <- gsub("%", "", c_score) #데이터 클리닝 
c_score <- as.numeric(c_score) #연산 위한 데이터 형식변경
#NAS 에러가 발생 : 평점이 ?로 표시된 값들이 존재하기때문
Sys.sleep(3)

remDr$navigate(m_url) # megabox 홈페이지 접속
Sys.sleep(2)
btn2 <- remDr$findElement(using="xpath", value='//*[@id="flip_wrapper"]/div/ul/li[2]/a')
btn2$clickElement() #예메율순 버튼클릭
Sys.sleep(2)
btn3 <- remDr$findElement(using="xpath", value='//*[@id="moreMovieList"]')
btn3$clickElement() #더보기 버튼클릭
Sys.sleep(2)
btn3$clickElement() #더보기 버튼클릭
Sys.sleep(2)
btn3$clickElement() #더보기 버튼클릭
Sys.sleep(2)

m_title <- remDr$findElements(using = "css", '.film_title')
m_title <- unlist(lapply(m_title, function(x) {x$getElementText()}))
m_title <- m_title[1:25] #영화 제목 저장 
m_title <- gsub("\\[", "", m_title) #데이터 클리닝 
m_title <- gsub("\\]", "", m_title)
m_title <- gsub(":", "", m_title)
m_title <- gsub("-", "", m_title)
m_score <- remDr$findElements(using = "css", '.fz14.pt2.pr9')
m_score <- unlist(lapply(m_score, function(x) {x$getElementText()}))
m_score <- m_score[1:25] #평점 데이터 저장 
m_score <- gsub("평점\n", "", m_score) #데이터 클리닝 
m_score <- gsub("\\.", "", m_score)
m_score <- as.numeric(m_score) #연산을 위한 데이터 형식 변경 
Sys.sleep(3)

remDr$navigate(l_url) # lottecinema 홈페이지 접속
Sys.sleep(2)
btn4 <- remDr$findElement(using="xpath", value='//*[@id="aMore2"]')
btn4$clickElement() #더보기 버튼클릭
Sys.sleep(2)
btn4$clickElement() #더보기 버튼클릭
Sys.sleep(2)
btn4$clickElement() #더보기 버튼클릭
Sys.sleep(2)
btn4$clickElement() #더보기 버튼클릭
Sys.sleep(2)
btn4$clickElement() #더보기 버튼클릭
Sys.sleep(2)

l_title = c()
for (i in 1:3){
  temp <- remDr$findElements(using = "xpath", sprintf('//*[@id="ulMovieList"]/li[%d]/dl/dt/a',i))
  l_title[i] <- unlist(lapply(temp, function(x) {x$getElementText()}))
}
#4번째에 광고가 있기 때문에 for문 분리
for (i in 5:26){
  temp <- remDr$findElements(using = "xpath", sprintf('//*[@id="ulMovieList"]/li[%d]/dl/dt/a',i))
  l_title[i-1] <- unlist(lapply(temp, function(x) {x$getElementText()}))
}
l_title <- gsub("12", "", l_title) #데이터 클리닝 
l_title <- gsub("15", "", l_title)
l_title <- gsub("전체", "", l_title)
l_title <- gsub("\\[", "", l_title)
l_title <- gsub("\\]", "", l_title)
l_title <- gsub(":", "", l_title)
l_title <- gsub("-", "", l_title)

l_score <- remDr$findElements(using = "css", '.list_score')
l_score <- unlist(lapply(l_score, function(x) {x$getElementText()}))
l_score <- l_score[1:25] #평점 데이터 저장 
l_score <- gsub("관람평점 ", "", l_score) #데이터 클리닝 
l_score <- gsub("\\.", "", l_score)
l_score <- as.numeric(l_score) #연산 위한 데이터 형식 변경 
Sys.sleep(2)
###########################################################################################################################
#영화 제목, 예메율, 평점, 평점평균 데이터프레임 생성
CGV = data.frame(title = c_title[1:10], A_Rate = c_adv[1:10], C_score = c_score[1:10]) #예매율 10위권 밖은 예매율0.1%이하로 의미없음 
MEGABOX = data.frame(title = m_title[1:10], M_score = m_score[1:10])
LOTTE = data.frame(title = l_title[1:10], L_score = l_score[1:10])

temp.m = merge(CGV, MEGABOX, by= "title") #Cgv 와 Megabox 타이틀기준으로 결합
final = merge(temp.m, LOTTE, by= "title") #마지막으로 Lottecinema와 결합 
final <- final[c(order(-final$A_Rate)),] #예매율순 정렬 
rownames(final) = NULL #인덱스값 초기화 
temp.d <- data.frame(final$C_score,final$M_score,final$L_score)
score.m <- round(rowMeans(temp.d, na.rm=T),0) #3사 평점평균 계산
final["Mean.score"] = score.m #평점 평균열 추가
final
###########################################################################################################################
#텔레그램 전송
for(i in 1:length(final$title)){ #telegrem message sending
  bot$sendMessage(chat_id = chat_id, text = as.character(final$title[i])) #영화제목 전송
  bot$sendMessage(chat_id = chat_id, text = final$A_Rate[i]) #예매율 전송
  bot$sendMessage(chat_id = chat_id, text = final$Mean.score[i]) #3사 평균평점 전송
  Sys.sleep(1)
}
###########################################################################################################################
#그래프 그리기 위한 데이터 프레임 새로만들기
cc=c()
mm=c()
ll=c()
for(i in 1:length(final$C_score)){
  cc[i] = "CGV"  
  mm[i] = "MegaBox"
  ll[i] = "LotteCinema"
}
Brand <- c(cc,mm,ll)
Title <- rep(final$title, 3)
Score <- c(final$C_score,final$M_score,final$L_score)
rfinal <- data.frame(Brand, Title, Score)
rfinal
###########################################################################################################################
#ggplot사용해 막대그래프 그리기
bar <- ggplot(rfinal, aes(x=Title, y=Score, fill=Brand)) #데이터 선택 
bar <- bar + geom_bar(stat="identity", position="dodge") #막대그래프 생성 
bar <- bar + geom_text(stat = "identity", aes(label=Score), position = position_dodge(width=0.9), vjust=-0.5) #데이터레이블 막대상단 추가
bar <- bar + ggtitle(label = '영화관 브랜드별 개봉영화 평점 비교') #타이틀 추가 
bar + theme(plot.title = element_text(face = 'bold', size = 20, hjust = 0.5)) + #타이틀 크기, 굵기, 가운데정렬 
  geom_point(aes(x=Title,y=Score),colour="black", position = position_dodge(width=0.9)) + #점 추가
  geom_hline(yintercept=mean(rfinal$Score), linetype='dashed') #평점평균 점선으로 추가 
###########################################################################################################################

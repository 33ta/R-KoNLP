#형태소 분석
#KoNLP::설치

install.packages("multilinguer")
library(multilinguer)
install_jdk()

install.packages(c("hash", "tau", "Sejong", "RSQLite", "devtools", "bit", "rex", "lazyeval", "htmlwidgets", "crosstalk", "promises", "later", "sessioninfo", "xopen", "bit64", "blob", "DBI", "memoise", "plogr", "covr", "DT", "rcmdcheck", "rversions"), type = "binary")

install.packages("remotes")
remotes::install_github("haven-jeon/KoNLP",
                        upgrade = "never",
                        INSTALL_opts = c("--no-multiarch"),
                        force = T)

install.packages("cli")
library(KoNLP)
useNIADic()

# 명사추출
extractNoun(data1$value) #tibble한 데이터에서 명사추출해야 함!


#txt 파일 불러오기
data <- readLines("abc.txt", encoding ="UTF-8")
head(data)

#데이터 전처리
install.packages("stringr")
library(stringr)
library(dplyr)
data1 <- data %>% 
  str_replace_all("[^가-힣]", " ") %>%    #한글만 남기기
  str_squish() %>%                        #연속된 공백 제거
  as_tibble()                             #tibble 변환

data1

#토큰화하기
install.packages("tidytext")
library(tidytext)
data2 <- data1 %>%
  unnest_tokens(input = value,       #토큰화할 텍스트
                output = word,       #출력변수명    
                token = extractNoun)     #단어기준("words") #명사기준(extractNoun)

data2

#단어빈도 구하기
install.packages("dplyr")

library(dplyr)
data3 <- data2 %>%
  count(word , sort = T) %>%          #단어 빈도
  filter(str_count(word) > 1)         #1글자 초과 단어만 남기기

data3

#상위 20개만 추출
data4 <- data3 %>%
  head(20)

data4

#막대 그래프 만들기
install.packages("ggplot2")
library(ggplot2)

ggplot(data4, aes(x = reorder(word, n), y = n)) +  #단어빈도순 정렬
  geom_col() +
  coord_flip() +  #회전
  geom_text(aes(label =n), hjust = -0.3) +      #막대 밖 빈도 표시
  
  labs(title = "단어빈도수",                         #그래프 제목
       x = NULL, Y= NULL) +                    #축 이름 삭제
  theme(title = element_text(size = 12),
        text = element_text(family = "nanumgothic"))      # 제목 크기


#워드클라우드 폰트 적용
install.packages("showtext")
library(showtext)

font_add_google(name = "Nanum Gothic", family = "nanumgothic") #나눔고딕
font_add_google(name = "Black Han Sans", family = "blackhansans") #검은고딕
font_add_google(name = "Gamja Flower", family = "gamjaflower") #감자꽃마을
showtext_auto()
#96번째 줄 확인하기


#워드클라우드 만들기
install.packages("ggwordcloud")
library(ggwordcloud)

ggplot(data4, aes(label = word, size = n, col = n)) +     
  geom_text_wordcloud(seed = 1234,
                      family = "blackhansans") +   #폰트적용
  scale_radius(limits = c(3, NA),           #최소, 최대 단어 빈도
               range = c(3, 30)) +          #최소, 최대 글자 크기
  scale_color_gradient(low = "#66aaf2",      #최소빈도색깔
                       high ="#004EA1") +   #최대빈도색깔
  theme_minimal()                           #배경없는 테마 적용

#끝
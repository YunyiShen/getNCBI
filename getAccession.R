require(rvest)
require(stringr)
require(XML)
require(RCurl)
library(Rwebdriver)

print("Open Selenium First PLZ")
session_root = 'http://localhost:5555/wd/hub/'
start_session(root = session_root,browser = "chrome", #change browser here
              javascriptEnabled = TRUE, takesScreenshot = TRUE,
              handlesAlerts = TRUE, databaseEnabled = TRUE,
              cssSelectorsEnabled = TRUE)


fullspclist = read.csv("fullNCBIspcID.csv") #species list, have taxaid, if not change the kewword to taxa name

keywords = c("COX1","cds")
DNAtype = "linear"# or circular

urlleft = "https://www.ncbi.nlm.nih.gov/nuccore/?term=txid"
urlright = paste("+","\"",paste(keywords,collapse='"+"'),"\"")

Accession = data.frame(fullspclist,accession=NA)
dir.creat('./temp')
for(i in 1:nrow(fullspeclist)){
  print(as.character(Accession$spcname[i]))
  print(i)
  url = paste0(urlleft,as.character(Accession$spcID[i]),urlright)# if no taxaid, comment this line
  url = paste0(urlleft,as.character(Accession$spcname[i]),urlright)# if have taxaid comment this line
  post.url(url)
  Sys.sleep(1.5)
  get.html = page_source()
  writeLines(get.html,paste0("./temp/",as.character(Accession$spcname[i]),'.txt'))
  get.html = readLines(paste0("./temp/",as.character(Accession$spcname[i]),'.txt'))
  Mito = get.html[regexpr(DNAtype,get.html)!=-1 ]
  if(length(get.html)<=389 & length(Mito)==0){
    print("no target!")
    file.remove(paste0("./temp/",as.character(Accession$spcname[i]),'.txt'))
    next
  }
  
  if(length(Mito)==0){
    Mito = get.html[regexpr("NCBI Reference Sequence: ",get.html)!=-1]
    if(length(Mito)==0){
      Mito = get.html[regexpr('<p class="itemid">GenBank: ',get.html)!=-1] 
    }
  if(length(Mito)==0){
    print("no target!")
    file.remove(paste0("./temp/",as.character(Accession$spcname[i]),'.txt'))
    next
  }
  else{
    acc = str_extract(Mito,pattern = 'Sequence: .*?\\.')
    acc = sub('Sequence: ','',sub('\\.','',acc))
    if(length(acc)==1){
      acc = str_extract(Mito,pattern = 'GenBank: .*?</p>')
      acc = sub('GenBank: ','',sub('</p>','',acc))
    }
  }
    print(acc)
    Accession[i,3]=na.omit(acc)[1]
    file.remove(paste0("./temp/",as.character(Accession$spcname[i]),'.txt'))
    next
  }
  
  acc = str_extract(Mito,pattern = '/nuccore/.*?\\.')
  acc = sub("/nuccore/","",sub("\\.","",acc))
  if(is.na(acc)){
    acc = str_extract(Mito,pattern = '   .*?        ')
    acc = gsub(pattern=substr(acc,1,2),'',acc)
    acc = gsub(" ",'',acc)
  }
  print(acc)
  Accession[i,3]=na.omit(acc)[1]
  file.remove(paste0("./temp/",as.character(Accession$spcname[i]),'.txt'))
}
unlink("./temp"，recursive=TRUE) 
write.csv(Accession,paste0(paste(keywords,collapse='_'),'.csv'),row.names = F)

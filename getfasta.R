require(rvest)
require(XML)
require(RCurl)
require(Rwebdriver)

workdir = 'I:/Yunyi/2.Pheasant/Pheasant Phylogeny/NCBI all pheasants' # change to work direction
savedir = paste(workdir,'Mito',sep = '/') # where fasta file saved
setwd(workdir)
urlleft = 'https://www.ncbi.nlm.nih.gov/nuccore/'
urlright = '?report=fasta'
session_root = 'http://localhost:5555/wd/hub/'
start_session(root = session_root,browser = "chrome",
              javascriptEnabled = TRUE, takesScreenshot = TRUE,
              handlesAlerts = TRUE, databaseEnabled = TRUE,
              cssSelectorsEnabled = TRUE)



specieslist = read.csv('NCBI_MB.csv') # name of accession and spp. list
specieslist = na.omit(specieslist)
specieslist$spcname = as.character(specieslist$spcname) #make species name character
specieslist$accession = as.character(specieslist$accession) #make accession character



for(i in 1:nrow(specieslist)){
  filename = paste0(savedir,'/',specieslist$spcname[i],'.txt')
  fasfile = file(filename,'w')
  species = specieslist$spcname[i]
  url = paste0(urlleft,specieslist$accession[i],urlright)
  post.url(url)
  Sys.sleep(5)
  print(species)
  print(i/nrow(specieslist))
  get.html = page_source()
  page.source = htmlParse(get.html,asText = T,encoding = 'UTF-8')
  fasta1 = page.source %>% getNodeSet('//pre')  
  fasta = fasta1[[1]] %>% xmlValue()
  writeLines(fasta,fasfile)
  writeLines('\n',fasfile)
  close(fasfile)
} # save fasta to txt files



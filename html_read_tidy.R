library(rvest)
library(stringr)
library(purrr)
library(tibble)
library(conflicted)
conflict_prefer("pluck", "purrr")

# you should add any further URLs to this vector
urls <- c("http://bocyl.jcyl.es/html/1983/04/02/html/BOCYL-D-02041983-1.do")

text <- urls %>%
  map(., ~ {xml2::read_html(.) %>%
      rvest::html_nodes("#presentDocumentos p:not([class])") %>% 
      html_text})

names(text) <- urls %>% 
  str_extract_all(., pattern = "(?<=/)BOCYL.*(?=\\.do$)")

# do any manual fixes to broken data here
text1 <- text %>% 
  map(., ~
  str_replace_all(., "PARTIDO COMUNISTA DE ESPAÑA PARTIDO COMUNISTA DE CASTILLA- LEON", "2. PARTIDO COMUNISTA DE ESPAÑA PARTIDO COMUNISTA DE CASTILLA- LEON"))

text2 <- text1 %>%
  map(., ~ 
        str_replace_all(., "(\\.)*(\\s)*$", "") %>% 
        str_replace_all(., "(\\s)+", " ") %>% 
        str_replace_all(., "^Suplente.*", "") %>% 
        str_c(., collapse = ";") %>% 
        str_split(., pattern = "JUNTA ELECTORAL DE ") %>% 
        modify_in(., 1, ~ tail(., -1)) %>% 
        map(., ~ str_split(.,
                           pattern = ";(?=\\d{1,2}\\.\\s([:upper:]|\\s){2,})") %>% 
              set_names(str_to_title(map(., 1))) %>% 
              map(., ~ tail(., -1))
            )
  )

# test with Avila only first
text2[[1]][[1]][["Avila"]] %>% 
  map(., ~ str_split(., pattern = ";(?=\\d{1,2}\\.\\s)") %>% 
        set_names(map(., 1) %>% 
                    str_extract(., pattern = "(?<=\\d{1,2}\\.\\s)[:upper:].*")) %>% 
        map(., ~ tail(., -1))
      )


text3 <- text2 %>% 
  pluck(., 1, 1) %>% 
  map(.,  ~ str_split(.,
                      pattern = ";(?=\\d{1,2}\\.\\s)") %>% 
        set_names(map(., 1) %>% 
                    str_extract(., pattern = "(?<=\\d{1,2}\\.\\s)[:upper:].*")) %>% 
        map(.,
            ~ tail(., -1)))


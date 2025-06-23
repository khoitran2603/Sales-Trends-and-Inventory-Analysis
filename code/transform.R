###LIBRARY
library(tidymodels)
library(stringr)
library(tidyverse)
library(parsnip)
library(dplyr)
library(tidyr)
library(ggplot2)
library(tidytext)
library(lubridate)
library(ggcorrplot)
library(timetk)


###DATASET IMPORT
sales <- readr::read_csv("transactions.csv")

###DATA WRANGLING & CLEANING
sales_clean <- sales %>%
  rename_all(tolower) %>%
  rename(
    item_type = `itemisation type`, 
    gross_sales = `gross sales`, 
    product_sales = `product sales`
    ) %>%
  mutate(
    gross_sales = as.numeric(str_remove(gross_sales, "\\$")),
    product_sales = as.numeric(str_remove(product_sales, "\\$")),
    discounts = as.numeric(str_remove(discounts, "\\$")),
    tax = as.numeric(str_remove(tax, "\\$"))
    ) %>%
  select(date,category,item_type,item,qty,gross_sales,product_sales,discounts,tax)

product_sales <- sales_clean %>%
  filter(item_type == "Physical Good") %>%
  filter(category != "Beverages") %>%
  filter(!str_starts(item, "Bottle - ")) %>%
  filter(!str_starts(item, "Drink - ")) %>%
  filter(!str_starts(item, "Tea - ")) %>%
  filter(!str_starts(item, "Energy Drink - ")) %>%
  filter(item != "Drink can") %>%
  filter(item != "Damaged Item") %>% 
  filter(item != "Gloss Varnish") %>% 
  filter(item != "Soy Milk") %>% 
  filter(item != "Take-home kit") %>%
  filter(item != "Extra Paints") %>%
  filter(item != "Extra - Colour Tube") %>%
  filter(item != "Return to Paint") %>%
  filter(gross_sales > 0) %>%
  filter(item != "Imperfect") %>%
  filter(between(month(date), 5, 10)) %>%
  select(-item_type)

##Corrected name
product_sales <- product_sales %>%
  mutate(item = str_remove_all(item, "Ltd Ed - "),
        item = str_replace_all(item, "BuBu LaLa", "Bubu Lala"),
        item = str_replace_all(item, "Lion Skullpanda", "SP - Lion Dance"),
        item = str_replace_all(item, "Ducky - Star", "Ducky Star"),
        item = str_replace_all(item, "Ducky - Bag", "Ducky With Little Bag"),
        item = str_replace_all(item, "Cat Lady - Bottle", "Cat - Lady"),
        item = str_replace_all(item, "Cinamonroll", "Cina"),
        item = str_replace_all(item, "Cinamon queen", "Cina - Queen"),
        item = str_replace_all(item, "Cina with hat", "Cina - Magician Hat"),
        item = str_replace_all(item, "Captain US Doremon", "Dor - Captain US"),
        item = str_replace_all(item, "doreamon batman", "Dor - Bat"),
        item = str_replace_all(item, "Dora|Doremon", "Dor"),
        item = str_replace_all(item, "Doremon - Headphone|Headphone Doremon", "Dor - Headphones"),
        item = str_replace_all(item, "Baby Dragon", "Dragon - Baby"),
        item = str_replace_all(item, "Cute Dragon", "Dragon - Cute"),
        item = str_replace_all(item, "Fox Nine Tailed - Large", "Fox - Nine Tailed"),
        item = str_replace_all(item, "Fox Nine Tailed - Small|Nine Tailed Fox", "Fox - Nine Tailed (small)"),
        item = str_replace_all(item, "Kuromi - Clown", "Kuro - Clown Hat"),
        item = str_replace_all(item, "Kuromi - Bowtie", "Kuro - Bowtied"),
        item = str_replace_all(item, "Kuromi - Evil Large", "Kuro - Evil"),
        item = str_replace_all(item, "Kuromi - With Hat", "Kuro - Magician Hat"),
        item = str_replace_all(item, "Kuromi - Dragon", "Kuro - Dragon"),
        item = str_replace_all(item, "Kuromi Eclipse", "Kuro - Eclipse"),
        item = str_replace_all(item, "Kuromi - Heart", "Kuro - Heart"),
        item = str_replace_all(item, "Lion - Large", "Lion King"),
        item = str_replace_all(item, "Lion - Smal|Lion Babyl", "Lion Baby"),
        item = str_replace_all(item, "Melody", "Mel"),
        item = str_replace_all(item, "Bowtied Melody|Bowtied Mel", "Mel - Bowtied"), 
        item = str_replace_all(item, "Monsters Inc. Sully Large", "Monster - Suli & Mike"),
        item = ifelse(item == "Monster", "Monster small", item),
        item = str_replace_all(item, "Piggy The Queen", "Piggy - Queen"),
        item = str_replace_all(item, "Piggy Birthday", "Piggy - Birthday"),
        item = str_replace_all(item, "Smile Bathtub Piggy", "Piggy - Bathtub"),
        item = str_replace_all(item, "Piggy Happy", "Piggy - Happy"),
        item = str_replace_all(item, "Piggy Bottle", "Piggy - Bottle"),  
        item = str_replace_all(item, "Piggy - Peach|Piggy - Peachyy", "Piggy - Peachy"),
        item = str_replace_all(item, "pokemon - icecream", "Pok - Ice Cream"),
        item = str_replace_all(item, "Pokemon - Blastoise", "Pok - Blas Turtle"), 
        item = str_replace_all(item, "Pokemon - psyduck", "Pok - Psy Duck"),
        item = str_replace_all(item, "Pikachu on Saturn", "Pok - Pi on Saturn"), 
        item = str_replace_all(item, "Pot Lady 1", "Pot Lady - Large"),
        item = str_replace_all(item, "Pot Lady 2", "Pot Lady - Small"),
        item = str_replace_all(item, "Pot Lady 3", "Pot Lady - Small"),
        item = str_replace_all(item, "Pot Lady Small - 1", "Pot Lady - Small"),
        item = str_replace_all(item, "Pot Lady Small - 2", "Pot Lady - Small"),
        item = str_replace_all(item, "Pot Lady Large - 2", "Pot Lady - Large"),
        item = str_replace_all(item, "Pot Lady Large - 1", "Pot Lady - Large"),
        item = str_replace_all(item, "Sanrio - Pompompurine", "Pompom"), 
        item = str_replace_all(item, "Rabbit on Ducky", "Rabbit on Duck"),
        item = str_replace_all(item, "Sleeping Angel", "Angel - Sleeping"),
        item = str_replace_all(item, "Bear Strawberry", "Strawberry Bear"),
        item = str_replace_all(item, "Bear - Astro", "Astro Bear"),
        item = str_replace_all(item, "Prism Bear", "Bear - Prism"),
        item = str_replace_all(item, "Hello Kitty Holder", "Bowtie Cat - Holder"),
        item = str_replace_all(item, "Sanrio Holder", "Holder"),
        item = str_replace_all(item, "Lucky Skull Panda", "Skull Panda - Lucky"),
        item = str_replace_all(item, "Hello Kitty Baby|Hello kitkat|Hello kitty", "Bowtie Cat"),
        item = str_replace_all(item, "Sailor Hello Kitty", "Bowtie Cat - Sailor"),
        item = str_replace_all(item, "Kirby", "Kir"),
        item = str_replace_all(item, "Kirby on Star", "Kir - On Star"),
        item = str_replace_all(item, "Lava", "Larva"),
        item = str_replace_all(item, "Rabbit Ducky", "Rabbit on Duck"),
        item = str_replace_all(item, "teddy bear|Teddy With Tote", "Teddy with Tote"),
        item = str_replace_all(item, "Puppy - Glasses", "Puppy"),
        item = str_replace_all(item, "Jerry - Disney Cheesy Mouse", "Terry - Cheesy Mouse"),
        item = str_replace_all(item, "–", "-")
) 
  
for (i in 2:nrow(product_sales)) {
  is_skull_panda <- str_detect(product_sales$item[i], "Skull Panda")
  has_number     <- str_detect(product_sales$item[i], "\\b[1-6]\\b")
  
  if (is_skull_panda && has_number) {
    product_sales$item[i] <- product_sales$item[i - 1]
  }
}

##Split item into proper type & name
product_sales <- product_sales %>%
  mutate(
    type = case_when(
      str_starts(item, "Halloween - ") ~ "Halloween", 
      str_starts(item, "SP - ") | str_detect(item, "Skull Panda|Skullpanda") ~ "SP",              #Skull Panda
      str_starts(item, "Astronaut - ") | item == "Astronaut" ~ "Astronaut",                       #Astronaut
      str_detect(category, "Bear Stick") | str_starts(item, "Bear Stick - ") ~ "Bear Stick",      #Bear Stick
      str_starts(item, "Bear Brick - ")  ~ "Bear Brick",                                          #Bear Brick
      str_starts(item, "Bear - ") ~ "Bear",                                                       #Bear
      str_starts(item, "Lotso Bear - ") | str_detect(item, "Lotso Bear")  ~ "Lotso Bear",         #Lotso Bear
      str_starts(item, "Bear Holder - ") | item == "Bear Holder" ~ "Bear Holder",                 #Bear Holder
      str_starts(item, "Holder - ") | item == "Holder" ~ "Holder",                                #Holder
      str_starts(item, "Bowtie Cat - ") ~ "Bowtie Cat",                                           #Bowtie Cat
      str_starts(item, "Capybara - ") | item == "Capybara" ~ "Capybara",                          #Capybara
      str_starts(item, "Cat - ") ~ "Cat",                                                         #Cat
      str_starts(item, "Cina - ") | item == "Cina" ~ "Cina",                                      #Cina
      str_starts(item, "Couple - ") ~ "Couple",                                                   #Couple
      str_starts(item, "Dino") ~ "Dino",                                                          #Dino
      str_starts(item, "Dor - ") | item == "Dor" ~ "Dor",                                         #Doraemon
      str_starts(item, "Dragon - ") ~ "Dragon",                                                   #Dragon
      str_starts(item, "Fox - ") ~ "Fox",                                                         #Fox
      str_starts(item, "Kuro - ") ~ "Kuro",                                                       #Kuromi
      str_starts(item, "Larva - ") | item == "Larva" ~ "Larva",                                   #Larva
      item == "Lion King" | item == "Lion Baby" ~ "Lion",                                         #Lion
      item == "Chicken Mama" | item == "Mama Chicken - 2" ~ "Chicken Mama",                       #Chicken Mama
      str_starts(item, "Mel - ") | item == "Mel" ~ "Mel",                                         #Melody
      str_starts(item, "Monster - ") | item == "Monster small" ~ "Monster",                       #Monster
      str_starts(item, "Piggy - ") ~ "Piggy",                                                     #Piggy
      str_starts(item, "Pok - ") ~ "Pokemon",                                                     #Pokemon
      str_detect(item, "Pot Lady - ") ~ "Pot Lady",                                                  #Pot Lady
      str_starts(item, "Rabbit - ") | item == "Rabbit on Duck"  ~ "Rabbit",                       #Rabbit
      str_starts(item, "Raws - ") ~ "Raws",                                                       #Raws
      str_starts(item, "Angel - ") ~ "Angel",                                                     #Angel
      str_starts(item, "Strawberry Bear - ") | item == "Strawberry Bear"  ~ "Strawberry Bear",    #Strawberry Bear
      str_starts(item, "Beaver - ") ~ "Beaver",                                                   #Beaver
      str_starts(item, "Bubu Lala - ") | item == "Bubu Lala"  ~ "Bubu Lala",                      #Bubu Lala
      str_starts(item, "Doll - ") ~ "Doll",                                                       #Doll
      str_starts(item, "Dom - ") | str_starts(item, "Terry - ") ~ "Dom & Terry", 
      item == "Ducky Star" | item == "Ducky With Little Bag" ~ "Ducky",  
      item == "Hello kitkat" | item == "Hello kitty" ~ "Hello", 
      str_starts(item, "Kaws - ") | item == "Kaws"  ~ "Kaws", 
      str_starts(item, "Luff - ") | item == "Luffy"  ~ "Luffy", 
      str_starts(item, "Mitch - ") ~ "Mitch", 
      str_starts(item, "Ninja Pizza - ") ~ "Ninja Pizza", 
      str_starts(item, "Stitch - ") ~ "Stitch", 
      TRUE ~ item),
    name = case_when(
      type == "Halloween" ~ str_remove(item, "^Halloween -?\\s*"),
      type == "SP" ~ str_remove(item, "^SP - |^Ltd Ed - |^Skull Panda - |^Skull Panda\\s*-?\\s* |^Skullpanda - |^Skull Panda\\s*-?\\s*"),
      type == "Astronaut" ~ str_remove(item, "^Astronaut -?\\s*"),
      type == "Bear Stick" ~ str_remove(item, "^Bear Stick -?\\s" ),
      type == "Bear Brick" ~ str_remove(item, "^Bear Brick -?\\s"),
      type == "Bear" ~ str_remove(item, "^Bear -?\\s*"),
      type == "Lotso Bear" ~ str_remove(item, "^Lotso Bear -?\\s*"),
      type == "Bear Holder" ~ str_remove(item, "^Bear Holder -?\\s*"),
      type == "Holder" ~ str_remove(item, "^Holder -?\\s*"),
      type == "Bowtie Cat" ~ str_remove(item, "^Bowtie Cat -?\\s*"),
      type == "Capybara" ~ str_remove(item, "^Capybara -?\\s*"),
      type == "Cat" ~ str_remove(item, "^Cat -?\\s*"),
      type == "Cina" ~ str_remove(item, "^Cina -?\\s*"),
      type == "Couple" ~ str_remove(item, "^Couple -?\\s*"),
      type == "Dino" ~ str_trim(str_remove(item, "^Dino -?\\s*")),
      type == "Dor" ~ str_remove(item, "^Dor -?\\s*"),
      type == "Dragon" ~ str_remove(item, "^Dragon -?\\s*"),
      type == "Fox" ~ str_remove(item, "^Fox -?\\s*"),
      type == "Kuro" ~ str_remove(item, "^Kuro -?\\s*"),
      type == "Larva" ~ str_remove(item, "^Larva -?\\s*"),
      type == "Lion" ~ str_remove(item, "^Lion?\\s*"),
      item == "Chicken Mama" ~ "1",
      item == "Mama Chicken - 2" ~ str_remove(item, "^Mama Chicken -?\\s*"),
      type == "Mel" ~ str_remove(item, "^Mel -?\\s*"),
      type == "Monster" ~ str_remove(item, "^Monster -?\\s*"),
      type == "Piggy" ~ str_remove(item, "^Piggy -?\\s*"),
      type == "Pokemon" ~ str_remove(item, "^Pok -?\\s*"),
      type == "Pot Lady" ~ str_remove(item, "^Pot Lady -?\\s*"),
      type == "Rabbit" ~ str_remove(item, "^Rabbit -?\\s*"),
      type == "Raws" ~ str_remove(item, "^Raws -?\\s*"),
      type == "Angel" ~ str_remove(item, "^Angel -?\\s*"),
      type == "Strawberry Bear" ~ str_remove(item, "^Strawberry Bear -?\\s*"),
      type == "Beaver" ~ str_remove(item, "^Beaver -?\\s*"),
      type == "Bubu Lala" ~ str_remove(item, "^Bubu Lala -?\\s*"),
      type == "Doll" ~ str_remove(item, "^Doll -?\\s*"),
      str_starts(item, "Dom - ") ~ item,
      str_starts(item, "Terry - ") ~ item,
      type == "Ducky" ~ str_remove(item, "^Ducky?\\s*"),
      type == "Hello" ~ str_remove(item, "^Hello?\\s*"),
      type == "Kaws" ~ str_remove(item, "^Kaws -?\\s*"),
      type == "Luffy" ~ str_remove(item, "^Luffy -?\\s*"),
      type == "Mitch" ~ str_remove(item, "^Mitch -?\\s*"),
      type == "Ninja Pizza" ~ str_remove(item, "^Ninja Pizza -?\\s*"),
      type == "Stitch" ~ str_remove(item, "^Stitch -?\\s*"),
      TRUE ~ item  
    )
  ) %>% select(-category)

product_sales <- product_sales %>%
  mutate(item = ifelse(type == name, type, paste(type, name, sep = " - "))) %>% 
  rename(purchase_date = date)


# Write the summarized data to a text file with proper headers
write.table(product_sales, 
            file = "product_sales.csv",  # Specify your desired path
            sep = ",",  # Use tab as separator for better readability
            row.names = FALSE,  # Don't include row names
            quote = TRUE)  # Optionally include quotes around character data





library(dplyr)
library(readr)
library(ggplot2)
library(GGally)
library(tidyr)
library(purrr)

data_fixed <- read.csv('./data/fixed/data_nomissing.csv')
data_fixed$predict <- factor(data_fixed$predict, levels=c(0,1), labels=c('No', 'Yes'))

brand_preference_plot_plain <- ggplot(data_fixed, aes(brand)) +
    geom_bar() +
    ggtitle('Customer Brand Preference') +
    xlab('Brand Preference') +
    ylab('Customers')

brand_preference_plot_marked <- ggplot(data_fixed, aes(brand, fill=predict)) +
    geom_bar() +
    ggtitle('Customer Brand Preference') +
    xlab('Brand Preference') +
    ylab('Customers') + 
    guides(fill=guide_legend(title='Predicted'))

ggsave('./figures/brand_preference_plain.png', plot=brand_preference_plot_plain)
ggsave('./figures/brand_preference_marked.png', plot=brand_preference_plot_marked)

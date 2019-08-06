library(dplyr)
library(readr)
library(ggplot2)
library(GGally)
library(tidyr)
library(purrr)

data_fixed <- read.csv('./data/fixed/data_nomissing.csv')
data_fixed$predict <- factor(data_fixed$predict, levels=c(0,1), labels=c('Non-missing', 'Predicted'))

brand_preference_plot_plain <- ggplot(data_fixed, aes(brand, fill=brand)) +
    geom_bar(position='stack') +
    ggtitle('Customer Brand Preference') +
    xlab('Brand Preference') +
    ylab('Customers') +
    guides(fill=guide_legend(title='Brand'))

brand_preference_plot_marked <- ggplot(data_fixed, aes(brand, fill=brand)) +
    geom_bar(position='stack') +
    facet_grid(.~predict) +
    ggtitle('Customer Brand Preference: Non-Missing VS Predicted') +
    xlab('Brand Preference') +
    ylab('Customers') +
    guides(fill=guide_legend(title='Brand'))

brand_preference_plot_marked <- ggplot(data_fixed, aes(brand, fill=brand)) +
    geom_bar(position='stack') +
    facet_grid(.~predict) +
    ggtitle('Customer Brand Preference: Non-Missing VS Predicted') +
    xlab('Brand Preference') +
    ylab('Customers') +
    guides(fill=guide_legend(title='Brand'))
 
brand_preference_plot_marked_percentages <- ggplot(data_fixed, aes(x='', fill=brand)) +
    geom_bar(position='fill') +
    facet_grid(.~predict) +
    ggtitle('Customer Brand Preference: Non-Missing VS Predicted %') +
    xlab('Brand Preference') +
    ylab('Customers %') +
    guides(fill=guide_legend(title='Brand')) +
    scale_y_continuous(labels=scales::percent)

ggsave('./figures/brand_preference_plain.png', plot=brand_preference_plot_plain)
ggsave('./figures/brand_preference_marked.png', plot=brand_preference_plot_marked)
ggsave('./figures/brand_preference_marked_percentages.png', plot=brand_preference_plot_marked_percentages)

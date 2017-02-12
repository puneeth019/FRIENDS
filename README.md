## The One with All the Data :D

The idea is to analyze and understand the contribution of all the Lead Characters of [F.R.I.E.N.D.S TV series (1994-2004)](https://en.wikipedia.org/wiki/Friends) in-terms of number of dialogues spoken by them.


Lead Characters/*The FRIENDS* in this series are **Chandler, Joey, Monica, Phoebe, Rachel** and **Ross**.

### Some notes on data scraping

Data is scraped from episode **transcipts** which are in the form of `html` files. These transcripts can be downloaded originally from [here](http://www.friendstranscripts.tk/) or from my [repo](https://github.com/puneeth019/F.R.I.E.N.D.S/tree/master/transcripts)

## Observations

### Rachels speaks the most!

In the below plot you can see Number of dialogues (**#dialogues**) spoken in all **Ten Seasons** by  each Lead-Characters.

![alt text](https://github.com/puneeth019/F.R.I.E.N.D.S/blob/master/plots/%23Num_Dial_vs_character.png "Number of Dialogues vs. character")

Overall **#dialogues** by all characters are kind of close to each other's, with **Rachel** delivering the highest *(15,707)* and **Phoebe** the least*(12,443)*. **Chandler***(14,091)*, **Joey***(13,865)* & **Monica***(14,032)* are in the same league and **Rachel*8 & **Ross***(15174)* are in the other. I guess you can expect that **Phoebe** has the least *#dialogues*.

### Number of Dialogues in each Season

![alt_text](https://github.com/puneeth019/F.R.I.E.N.D.S/blob/master/plots/%23Num_Dial_vs_season.png "Number of Dialogues vs. Season")

   **Season 6** has the *highest* #dialogues (10,897) out of all Ten seasons. And season 5 *(10,738)*, season 6 & season 7*(10,798)* have almost same #dialogues. Maybe the writers tended to create more contect toward the middle of the series.

   And also it is obvious that something went wrong while extracting data for **Season 2** as #dialogues for this season*(1,416)* are pretty less compared with all other seasons. I have to revisit the scrit again to extract the data properly for this season. And it's also worth to check data extraction script for season 10 as well as #dialogues for this season *(4,392)* doesn't compare well with others.

**The plot below tells us who spoke the most in each season**.

![alt_text](https://github.com/puneeth019/F.R.I.E.N.D.S/blob/master/plots/%23Perc_Dial_vs_season.png "Percentage of Dialogues vs. Season")

Even from this plot it's clear that Phoebe has the least #dialogues in the series.

### Number of Dialogues by each Character in each season

![alt_text](https://github.com/puneeth019/F.R.I.E.N.D.S/blob/master/plots/Cyclic_Num_Dial_vs_ep_CHANDLER.png "Number of Dialogues by Chandler vs. Season") 

![alt_text](https://github.com/puneeth019/F.R.I.E.N.D.S/blob/master/plots/Cyclic_Num_Dial_vs_ep_JOEY.png "Number of Dialogues by Joey vs. Season")

![alt_text](https://github.com/puneeth019/F.R.I.E.N.D.S/blob/master/plots/Cyclic_Num_Dial_vs_ep_MONICA.png "Number of Dialogues by Monica vs. Season")

![alt_text](https://github.com/puneeth019/F.R.I.E.N.D.S/blob/master/plots/Cyclic_Num_Dial_vs_ep_PHOEBE.png "Number of Dialogues by Phoebe vs. Season")

![alt_text](https://github.com/puneeth019/F.R.I.E.N.D.S/blob/master/plots/Cyclic_Num_Dial_vs_ep_RACHEL.png "Number of Dialogues by Rachel vs. Season")

![alt_text](https://github.com/puneeth019/F.R.I.E.N.D.S/blob/master/plots/Cyclic_Num_Dial_vs_ep_ROSS.png "Number of Dialogues by Ross vs. Season")

The above plots show clear contribution of characters individually towards each season.
And even from the above plots it's clear that more work might be needed to extract data from **Seasons 2 & 10**.



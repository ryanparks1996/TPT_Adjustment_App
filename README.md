# TPT_Adjustment_App
Shiny R application to help store techs correct average ticket payouts that are either too much or too little.

Since games are played using a card/tap system, the measure used is simply the (total number of tickets) / (total number of taps).  
This Tickets Per Tap measure is abbreviated to TPT.

As a means to control merchandise costs, Chuck E. Cheese has two standards for average ticket payouts. One is at the individual game level. For games that actually give tickets, known as redemption games, the standard is to be between 2-6 TPT. The other standard is at the store level. It states if you take the TPT across all games, including the non-redemption games, the overall average should be between 2.9-3.1 TPT. Both standards are important; however, the latter is emphasized more.

There are times when the payouts of indivdual games need to be fine tuned to get the overall store TPT within the acceptable range. One example is when a store receives a new game package where a few games are swapped out with different ones. This is great for keeping the arcade experience feeling fresh, but it can easily mess up the store TPT depending on the games coming out and the ones coming in. Another example is that the company may want to adjust the target TPT. In the past two years, such an event has happened twice and is likely to happen again.

The purpose of this app is the following:  

1. Allow a store technician to input their store's weekly games metric report (aka TPT report)

2. Get a quick overview of the store's overall performance and see the worst offending games in terms of TPT

3. Pick one game and manually adjust its TPT value to see what the store's TPT would have been (theoretical TPT)

With this app, a technician will be able to quickly gain insights into their store's weekly performance and develop a strategy to fix an out-of-limits store TPT.

Quick note on how the theoretical TPT is calculated:  
It will take the user-inputted TPT value and multiply it by the total number of times that game was played. The result will be a new total ticket payout. 

Run this code remotely in any R enviroment using the runGitHub() function in any R environment. (Requires shiny package)  
Copy and paste the following: shiny::runGitHub("TPT_Adjustment_App", "ryanparks1996")

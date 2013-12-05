        __________
       /_____/  u \            The Grouper Social Club
       \_____\____ \           Cuttlefish Challenge
                 \\\\\


## Cuttlefish Challenge

At [Grouper Social Club](http://www.joingrouper.com/), we predict who you're going to get along with based on the content of your Facebook profile. Everyone who joins the club connects with Facebook. After our members go on a Grouper, we track whether or not they friend each other afterwards.

We've gotten pretty good at predicting friendships. Now, for the first time ever, we're letting curious hackers test their mettle against our data.

#### What's in this repo?

This repo contains two CSV files. Each row in the CSV has information for a pair of members that met each other on a grouper. Height is in inches and headers with asterisks are from our internal ratings and are intentionally mislabeled.

`training_data.csv` has a sample of 3500 pairs. The final column is a boolean that's `TRUE` when the members became friends after their Grouper

`test_data.csv` has a sample of 500 pairs. Your goal is to fill in the empty `members_became_friends` column as accurately as possible.

#### How do I get started?

Just submit a pull request with the filled in `test_data.csv` and the code that you used to get it.

#### How do you define a friendship?

For us to attribute a friendship to the Grouper, the two members must have become friends within 14 days of meeting each other on their grouper. All samples occurred at least 14 days ago. For simplicity, this challenge only includes male/female pairs. Approximately half of the members in both the training and test sets became friends afterwards.

All grouper members have been anonymized, and several fields have been renamed of course.

#### What's a cuttlefish?

The best fish. We call him Cthulhu (or Louis for short).

#### What do I get if I win?

If you win, we'll set you up with unlimited Groupers for life. Plus, we'll run every potential match that we set you up with against your algorithm, and only send you out if you're going to become friends.

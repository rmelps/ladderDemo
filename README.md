# Ladder Demo, How to Use the App
How to use the 7 day demo for Ladder.fit

## Prerequisites
I assume that you guys are familiar with Firebase/Cocoapods, but in order to run this project you may have to install the Firebase pods (by running $ pod install in a terminal window at the location of the downloaded Pod File). When doing so you need to add the app to a Firebase project on your Firebase console with the bundle id **com.j2mfd.LadderDemo**. The Home screens of both the Coach & User sides of the app utilize UIInterpolatingMotionEffects, so I would use a physical device when running it.

## Signing Up
Coaches and Users Sign up and Sign in through shared windows. After choosing whether you are a coach or user and signing up, you can log in through the "Sign In" button thereafter, and the app will automatically recognize if you are signing into a Coach or User profile.

## Coach Side

### Home Tab
- Change your Profile Picture by choosing existing photos from your Photo Library.
- Log Out.

### Assign Tab
- 5 preset promises are available by default, but can be deleted.
- New promises are added by pressing the "+" button in the top right corner, on the navigation bar.
- Swipe left on any row to choose to assign the currently selected user (who is selected through the User Tab) with the chosen promise. If no user is selected, you will be notified to select a user first. If a user is selected but does not have a promise for the current week, you will be able to choose to assign the promise for the current week or the following week.

### Promise Tab
- When a User is selected (through the User Tab), you will be able to see the selected users progress on a promise for the current week, with each day's completion status (complete or incomplete) displayed.
- Coach can not interact with this page, only observe. If a user is selected, their profile picture can be pressed for a cool little effect though

### Users Tab
- You can see all Users who have chosen you as their Coach (which is completed through the Coach tab on the User side of the app). You will NOT be able to see all users, and will not see any users if they have not chosen you as a Coach first.
- Selecting any of these cells will cause that user to become the Selected User, where the Promise and History Tabs will be populated with that specific user's data, and any actions taken on the Assign Tab will be attributed to this User.

### History Tab
- Historical data sorted by week, from most recent to least recent, can be seen on this tab
- Data Can not be interacted with, only observed.
- Completion status is displayed if the User was assigned a Promise that week. A progress bar can be seen, visualizing how many days of that specific week where the user completed their promise

## User Side

### Home Tab
- Change your Profile Picture by choosing existing photos from your Photo Library.
- Log Out.

### Promise Tab
- A User will be able to see their progress for the current week on their assigned Promise.
- The User will be able to complete their Promise here by pressing the Complete button. Promises can only be completed for the current day.

### Coach Tab
- The User is able to see ALL available coaches. The User's current coach is selected by default. Selecting any cell will change the User's coach to the selected Coach. Once selected, that Coach will be able to see the User in their side of the App, on the Users tab, and assign the User Promises.

### History Tab
- Same as for the Coach side, the User can see historical data which can not be interacted with, only observed.


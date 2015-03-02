


## Twitter Redux

This is a basic twitter app to read and compose tweets the [Twitter API](https://apps.twitter.com/).

Time spent: 26 hours

### Features

#### Required

- Hamburger menu
- [x] Dragging anywhere in the view should reveal the menu.
- [x] The menu should include links to your profile, the home timeline, and the mentions view.
- [x] The menu can look similar to the LinkedIn menu below or feel free to take liberty with the UI.

- Profile page
- [x] Contains the user header view
- [x] Contains a section with the users basic stats: # tweets, # following, # followers

#### Optional
- Profile page
- [ ] Optional: Implement the paging view for the user description.
- [ ] Optional: As the paging view moves, increase the opacity of the background screen. See the actual Twitter app for this effect
- [ ] Optional: Pulling down the profile page should blur and resize the header image.

- Home Timeline
- [x] Tapping on a user image should bring up that user's profile page
- [x] Optional: Account switching
- [x] Long press on tab bar to bring up Account view with animation
- [x] Tap account to switch to
- [x] Include a plus button to Add an Account
- [x] Swipe to delete an account

#### Notes
* Had some trouble with the header cell, needed to lookup way to calculate cell height--AutoLayout didn't like to figure it out automatically like normal cells.
* This in turn caused a constraint warning to come up for 'UIView-Encapsulated-Layout-Width' which I tried to fix by changing constraint priorities (per solutions on StackOverflow) but didn't seem to help. Luckily, this doesn't seem to cause any layout issues, however.
* Account switching does not save access tokens for multiple users so will have to login again while switching.

#### Credits
* [AFNetworking](https://github.com/AFNetworking/AFNetworking)
* [BDBOAuth1Manager](https://github.com/bdbergeron/BDBOAuth1Manager)
* [BDBSpinKitRefreshControl](https://github.com/bdbergeron/BDBSpinKitRefreshControl)
* [DateTools](https://github.com/MatthewYork/DateTools)
* [Twitter API/icons](https://dev.twitter.com)
* [Hamburger menu inspiration](http://uxmag.com/articles/adapting-ui-to-ios-7-the-side-menu)

### Walkthrough
![Video Walkthrough](https://github.com/drrajan/codepath-twitter/raw/master/walkthrough.gif)





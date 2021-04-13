# Contributing to Project-0

> - Please Read All Instructions to contribute to the project.
> - No project should be submitting a pull request to the main branch.

# How To Set Up Computer for use with local development

- Download Node.js [here](https://nodejs.org/en/)
- Download VSCode(Or other favorite Text Editor)

# Clone Main Branch
 
 - run git clone git@github.com:EX-Salesforce-Training/project-0-hard-day-s-byte.git in terminal

# Branch on Local

 - run "git checkout -b {name-of-business}" to create a new branch on your local repository

# Push Branch to Remote

 - run "git push origin {name-of-business}" to create a new branch on the remote repository on Github

# Working with Salesforce Developer Experience
 - Download sfdx CLI [here](https://developer.salesforce.com/tools/sfdxcli)
 - Authorize your production org by running "sfdx auth:web:login -a {name-of-business}"
 - Login to your org with proper username and password(Might have to get proper credentials from org)

# Creating a new Project and retrieving org data
 - Make sure you are in the folder for the cloned project in command line
 - Run "sfdx force:project:create projectname={name-of-business} --manifest"
 - New folder should be created in the name of your business
 - Navigate to this project folder in command line
 - Run "sfdx force:source:retrieve -u {name-of-business} -x ./manifest/package.xml"
 - You should now be able to find all of your classes and triggers from the org in the project you   created under the "force/main/default" folder
 - Add and commit your changes with "git add" and "git commit".
 - push new project to your branch with "git push origin {name-of-business}" and begin working locally with your code.

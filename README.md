# Anki - VS Code Debugging Integration
[@RisingOrange](https://github.com/RisingOrange)'s VSCode dev setup for Anki add-ons, forked by me to: 
- port to newer versions and Qt6
- use for other add-ons

Huge thanks to [RisingOrange](https://github.com/RisingOrange) for this. I don't know how to DM on GitHub - I wanted to send a thank-you message.

## About this project
- Great for debugging your add-on development in Anki! (debugging, variable inspections and code changes can be done **live**)
- Allows for a virtual environment with a new installation of Anki separate from your installation.
- Cross-platform compatible as long as you have **VS Code** and **pip** available.

# How to use
## Setting up virtual Python environment
- clone this repository to your device 
`git clone https://github.com/h0tp-ftw/anki-addon-vscode-setup.git /PATH/TO/DIRECTORY/`
- open the folder at /PATH/TO/DIRECTORY/anki-addon-vscode-setup in VS Code, then open the terminal in VS Code
- create a new python virtual environment in the folder
`python3 -m venv venv`
Here, the first venv is the command for a **virtual environment**, and second venv is for the **folder name**.
- activate this virtual environment
LINUX / MAC : `source venv/bin/activate`
WINDOWS : `venv\Scripts\activate`
- install the necessary packages via pip
`pip install -r requirements.txt`
- try running Anki in terminal by using command `anki`, it should work and it should be separate than your usual Anki installation ! 

## Setting up addon environment
- open Anki in terminal, and go to Add-Ons -> View Files to see where addons are stored (addons21).
- in this folder, either **add a symlink to your addon folder**, or a **copied folder of your addon**, or a **GitHub clone/branch of your addon** - it is upto you. 
#1 allows to sync changes with your native install, #2 is safer but you may have different environment or configurations, and #3 gives you great tracking but all addon files will be synced (sometimes thousands of changes can happen).
- now open the folder in VS Code. So you can open addon folder directly or the folder above it, whatever is convenient for you. 
- after opening, you should see a new `.vscode` folder has been added !
- copy the **launch.json** file from this repository and paste it in that folder (.vscode/launch.json) 
- open the `launch.json` file and edit it to change the Anki directory and to link to the anki binary in venv/bin. Make sure to have the FULL directory, not relative paths.

## Debugging addon code using virtual Python environment 
- open the `__init.py__` file for the addon. Note - this is the file we have to use to start our debugging! 
- use the `Python: Select interpreter` VSCode action to set the python interpreter to the one in the just created virtual environemnt (to your venv/bin/python binary)
- in the `__init.py__` file, use the function `Python Debugger: Debug using launch.json` to start debugging ! It may also show up as the name "Python 2.7 Anki", you might have to pick it every time before debugging. 

If Anki opens up when you do the debugging, CONGRATULATIONS! 

Once you learn about debugging, it can be very valuable to get your code tested !

## Limitations
- Anki addons can change thousands of files, so you should use this to test code changes and use another workspace to commit changes. Directly committing from this can be messy.
- Make sure to test your changes in native Anki before making any commits!
- ALWAYS debug using the init file! You can still debug other files, e.g. adding breakpoints and checking variables, but you have to start debugging at init file. 

## Screenshot of me using it in Ankimon
![Screenshot](https://raw.githubusercontent.com/h0tp-ftw/anki-addon-vscode-setup/refs/heads/master/Ankimon%20screenshot.png)

## Screenshots and recordings from @RisingOrange
<img src="https://user-images.githubusercontent.com/31575114/212190695-3b80024e-2de5-4a5b-ba7e-921a65ad365c.png" width=500>

<img src="https://user-images.githubusercontent.com/31575114/212190704-170d6d4c-945e-4be2-8607-d585e86e31de.png" width=500>


https://user-images.githubusercontent.com/31575114/212191360-8b0ac939-5da0-4b32-bacc-8959579b6d3b.mp4


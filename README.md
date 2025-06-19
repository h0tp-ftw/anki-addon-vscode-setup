# Anki - VS Code Debugging Integration
VSCode setup for debugging Anki add-ons, making add-on development more efficient!

- Debugging via breakpoints, variable inspections and code fixes can be done **live**
- Test code in Anki and make code changes directly within VS Code
- Quickly switch to other branches, tags and versions for your addon
- Cross-platform compatible and easy to set up!

# One-Step Commands for Running Setup Scripts

These commands are designed for installation of the [Ankimon (experimental)](https://github.com/h0tp-ftw/ankimon) addon. Please follow the steps below in the "How to set up step-by-step" section for other addons.

Dependencies: **VS Code** (duh), **Python** and **Git**

## macOS/Linux (Bash)

Run this command in your terminal:

   ```bash
   curl -fsSL https://raw.githubusercontent.com/h0tp-ftw/anki-vscode/refs/heads/master/setup.sh | bash
   ```

---

## Windows (PowerShell)

Open **PowerShell as Administrator** and run this command:

```powershell
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/h0tp-ftw/anki-vscode/refs/heads/master/setup.ps1' -OutFile 'setup.ps1'
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\setup.ps1
```
- this is not a virus (pinky promise)

Although this is not good security practice, I have set it up like this to allow for new contributors to easily be able to set up a debugging environment for Ankimon.
If you are concerned, you can follow the detailed steps given below. 

[![Star History Chart](https://api.star-history.com/svg?repos=h0tp-ftw/anki-vscode&type=Date)](https://www.star-history.com/#h0tp-ftw/anki-vscode&Date)

## Screenshot of me using it in Ankimon
![Screenshot](https://raw.githubusercontent.com/h0tp-ftw/anki-addon-vscode-setup/refs/heads/master/Ankimon%20screenshot.png)

Click on the image below (it is a VIDEO) to watch how I installed it on my device (no audio):
[![Watch the video](https://files.catbox.moe/qkujp4.png)](https://files.catbox.moe/svqhrb.mp4)

Huge thanks to [RisingOrange](https://github.com/RisingOrange) for this. I don't know how to DM on GitHub - I wanted to send a thank-you message.

## List of addons compatible with this setup
- Ankimon (Experimental) - [h0tp-ftw/ankimon](https://github.com/h0tp-ftw/ankimon) - v1.396E and above
- your addon could be here O_o

## How to make your addon compatible 
Imagine if you opened the addon in VS Code, and found out that files for your personal info are being tracked, and are considered in a push/pull/PR! That would be a disaster 😅

NOTE that to be compatible with the methods here, your addon must be set up so that cache files, user data files, and other files (which are not supposed to be pushed to the addon release on GitHub) are NOT PRESENT in the GitHub repo, and are properly ignored from tracking through a .gitignore file. If you need to regenerate those files when the user uses the addon for the first time, you can add functions to check if the file is present, and if not, dump the info from a Python function into that file. 

Once you do this, test it out by setting up the integration as given below. If set up correctly, after using your addon, your tracked changes will not show any user data files or cache files that were altered by using the addon.

# How to set up step-by-step
## Setting up virtual Python environment
- clone this repository to your device

```git clone https://github.com/h0tp-ftw/anki-vscode.git /PATH/TO/DIRECTORY/```

- open the folder at /PATH/TO/DIRECTORY/anki-vscode in VS Code, then open the terminal in VS Code

- create a new python virtual environment in the folder

```python3 -m venv venv```

Here, the first venv is the command for a **virtual environment**, and second venv is for the **folder name**.
- activate this virtual environment

LINUX / MAC : `source venv/bin/activate`

WINDOWS : `venv\Scripts\activate`
- install the necessary packages via pip

```pip install -r requirements.txt```

- try running Anki in terminal by using command `anki` or `./anki` in the virtual environment, it should work and it should be separate than your usual Anki installation ! 

## Setting up addon environment
- clone the repo for your addon to your device, any folder of your choice. Make sure your addon is compatible with this integration -    
- choose the directory where Anki data can be stored. This can be your native installation (Anki2 folder), or a new folder to keep it as a separate Anki installation. **Note that later, we will choose this directory using the launch.json file.**

- in this folder, make an `addons21` folder (if it is not there already) and **add a symlink to the correct addon folder for the GitHub clone/branch of your addon**.
  For example, if your github repo is h0tp-ftw/ankimon and the directory structure is repo / src / Ankimon for the actual addon content (which is to be used as the addon directory in a native install), then the symlink should point to wherever that folder is in your system. 

- now open the folder where you cloned the repo. (Not the addon folder or Anki folder - the folder where you cloned your addon repo to)

- after opening, you should see a new `.vscode` folder has been added !

- copy the **launch.json** file from this repository and paste it in that folder (.vscode/launch.json) 

- open the `launch.json` file and edit it to change the Anki directory and to link to the anki binary in venv/bin. Make sure to have the FULL directory, not relative paths. You can also link Anki directory to your native install - to get the same experience, files and addons as native.

## Debugging addon code using virtual Python environment 
- in VS Code, open the folder where you cloned the repo to.
  
- within that VS Code window, navigate to the `__init.py__` file for the addon. Note - this is the file we have to open to start our debugging! 

- use the `Python: Select interpreter` VSCode action to set the python interpreter to the one in the just created virtual environemnt (to your venv/bin/python binary)

- in the `__init.py__` file, use the function `Python Debugger: Debug using launch.json` to start debugging ! It may also show up as the name "Python Anki", you might have to pick it every time before debugging. 

If Anki opens up when you do the debugging, CONGRATULATIONS! 

Once you learn about debugging, it can be very valuable to get your code tested ! 

You can also repeat this guide to create multiple environments for your Anki add-ons !

## Limitations
- Anki addons can change thousands of files, so you should use this to test code changes and use another workspace to commit changes. Directly committing from this can be messy. MAKE SURE YOUR ADDON HAS A PROPERLY SET-UP GITIGNORE FILE THAT IGNORES ANY USER FILES.
- Make sure to test your changes in native Anki before making any commits! It is in a Python environment that is partially isolated from the system, so behaviour can be slightly different than system installations.
- ALWAYS debug using the init file! You can still debug other files, e.g. adding breakpoints and checking variables, but you have to start debugging at init file. 

If you see errors in package importing, likely that you didn't install all packages OR you didn't choose the correct interpreter path.

If you see errors in importing from relative paths, likely that you misconfigured the paths, or you are not linking the launch.json file 

## Screenshots and recordings from @RisingOrange
<img src="https://user-images.githubusercontent.com/31575114/212190695-3b80024e-2de5-4a5b-ba7e-921a65ad365c.png" width=500>

<img src="https://user-images.githubusercontent.com/31575114/212190704-170d6d4c-945e-4be2-8607-d585e86e31de.png" width=500>



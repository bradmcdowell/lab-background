# 🖼️ lab-background

These scripts set a custom **lab background** using the company logo.

The background is applied to:

- 🔒 **Lock screen** — shows the **hostname** in the top-right corner.
- 👤 **User desktop** — shows the **hostname and username** in the center of the screen.

> ⚙️ **Note:** You’ll need to modify the scripts if you plan to copy or run them from a different path.

---

## 📂 Share This Repository

Host this repo on a file share accessible in the lab, for example:

```
\\DC01\Distribution\lab-background\
```

---

## 📝 Add `info.txt`

Create a file named `info.txt` in the shared folder with the content you want shown in the **bottom-right corner** of the background.

**Location:**

```
\\DC01\Distribution\lab-background\info.txt
```

**Example Content:**

```
This appears in the bottom-right corner
```

---

## 🏛️ Create and Configure a Group Policy Object (GPO)

1. Create a new GPO.
2. Import the settings from the included `Lab-Background-GPO.zip`.

---

### 📥 What the GPO Does

The GPO copies the following files from the server:

```
\\DC01\Distribution\lab-background\Logo.png
\\DC01\Distribution\lab-background\Set-LockScreen.ps1
\\DC01\Distribution\lab-background\Set-UserWallPaper.ps1
\\DC01\Distribution\lab-background\info.txt
```

To this location on the endpoint:

```
C:\lab-background\Logo.png
C:\lab-background\Set-LockScreen.ps1
C:\lab-background\Set-UserWallPaper.ps1
C:\lab-background\info.txt
```

It also configures the following:

- 🧑 **User Configuration**: Runs `Set-UserWallPaper.ps1` at **logon**
- 🖥️ **Computer Configuration**: Runs `Set-LockScreen.ps1` at **startup**

---

✅ Once applied, users will see the updated background with your company branding and system info.

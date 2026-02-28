# 🔐 Admin Login - Simple Solution

## The Problem
Your email `nilimeshpal15@gmail.com` exists but has a different password than `Nilimesh@2002`.

## ✅ EASIEST SOLUTION (2 Minutes)

### Step 1: Register Fresh in App
1. **Open your LoveNest app**
2. **Click "Register" (not Login)**
3. **Use these details:**
   ```
   Name: Admin User
   Email: admin.lovenest@gmail.com
   Password: Admin@123456
   ```
4. **Complete registration** (verify email if needed)
5. **Login successfully**

### Step 2: Get Your Access Token
After logging in, check the console. You'll see:
```
🔑 ACCESS TOKEN FOR HOTEL INSERTION:
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```
Copy this token.

### Step 3: Set Admin Role
Run this command and paste your token:
```bash
dart run scripts/set_admin_role.dart
```

**Done!** You now have admin access.

---

## 🎯 Alternative: Use Your Existing Account

If you remember your original password for `nilimeshpal15@gmail.com`:

1. **Login with that password**
2. **Get access token from console**
3. **Run:** `dart run scripts/set_admin_role.dart`
4. **Paste token**
5. **Admin access granted!**

---

## 🔑 Try These Emails

You might have registered with one of these:

1. `nilimeshpal15@gmail.com` - Try your usual password
2. `nilimeshpal22@gmail.com` - Try your usual password  
3. `admin@lovenest.com` - Password: `LoveNest@Admin2024!`

---

## 💡 Quick Test

Try logging in with each email above using your common passwords. One should work!

---

## 🆘 If Nothing Works

**Register a completely new account:**

1. Open app → Register
2. Email: `youremail+admin@gmail.com` (use + trick)
3. Password: `Admin@123456`
4. Complete registration
5. Get token from console
6. Run: `dart run scripts/set_admin_role.dart`
7. Paste token
8. Admin access granted!

---

## 📞 Need More Help?

The issue is that your account exists with an unknown password. The simplest fix is to:
- Register a new account with known credentials
- Set it as admin using the script
- Use that for admin access

**Recommended Email:** `admin.lovenest@gmail.com`  
**Recommended Password:** `Admin@123456`

Just register this in your app, then run the admin role script!

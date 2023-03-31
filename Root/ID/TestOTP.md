Title: Test OTP
Description: Allows you to extract a OTP code for testing of the TAG ID App
Master: /Master.md
Author: Peter Waher
Date: 2022-04-06

Test OTP Code
=================

Find your OTP code for your test session below. Fill in the phone number provided when onboarding the app, and press the "Show" button
to retrieve the code for the corresponding number. If no code is found for the number, an error message will be displayed.

**Note**: An app onboarded with a test OTP code will only be valid for the duration of the test.

<fieldset>
<legend>Test OTP</legend>
<form action="TestOTP.md" method="POST">

<p>
<label for="PhoneNr">Phone Number:</label>  
<input type="text" name="PhoneNr" required="required" title="Phone Number, as entered in the ID App." value="{{Posted?.PhoneNr ??? ''}}"/>
</p>

{{if exists(Posted) then
(
	PrevCode:=0;
	if !Posted.PhoneNr.Replace(" ","").StartsWith("+1555") then
		]]<span class="error">Not a testing phone number. Phone number must start with `+1555`.</span>[[
	else if !exists(Global.VerifyingNumbers) or (!Global.VerifyingNumbers.TryGetValue(Posted.PhoneNr,PrevCode)) then 
		]]<span class="error">No verification code found for the corresponding number.</span>[[
	else
		]]Verification code: **((PrevCode))**[[
)}}

<p>
<button type="submit" class="posButton" title="Displays the verification code, if it exists">Show</button>
</p>
</form>
</fieldset>

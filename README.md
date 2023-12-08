Onboarding
=============

This repository contains APIs and script necessary to create custom onboarding of customized apps based on the TAG Digital ID or 
the Neuro Access Apps, pointing them to corresponding neurons, based on location, purpose of use and type of app.

Process
----------

The following process is used to onboard new TAG Digital ID-based apps:

1.	The app selects an **onboarding neuron** to help with the onboarding process. By default, this is `id.tagroot.io`. This
	is defined in the source code, using the constant `Constants.Domains.IdDomain`.

2.	The app makes a `POST` request to the `/ID/CountryCode.ws` resource on the onboarding neuron. All requests to the onboarding
	API must be encrypted. The web resource [CountryCode.ws](Root/ID/CountryCode.ws) looks up the IP address used by the app,
	and checks in what country it is registered, and returns the corresponding international phone country code to the client.

3.	The app then requests the user of the app to provide an e-mail address and phone number, for the registration. Requesting
	the e-mail address is optional. The phone number is required. It is after validating the phone number, that credentials
	are returned allowing the app to create an account.

4.	For each phone number or e-mail address provided, the app requests the onboarding neuron to send a corresponding verification
	e-mail message or sms message. This is done by calling the `/ID/SendVerificationMessage.ws` resource. Some things to note:

	*	The resource employs a protection mechanism by using a Login-auditor monitoring login attempts. Only a certain number
		of failed login attempts in a row is permitted. After that, the IP address gets a temporary ban. If continuing to
		perform failed login attempts, the IP address can become permanently banned. Number of attempts, and temporary ban
		durations are set in the neuron. A banned address can be manually unblocked by the operator of the neuron.

	*	E-mail message are sent by the neuron itself. If an e-mail relay is configured (`/Settings/Relay.md` on the neuron),
		messages are sent via this e-mail relay. The actual mail message is formed using [Markdown][], and then sent using the
		`SendMail` [script][] function to the recipient.

	*	SMS messages are sent using the web service provided by [textlocal.com][]. You need an API key to
		this service, if you're going to reuse the same implementation in your customized ID onboarding API. (You can also replace
		this implementation with another messaging service.) The API Key to the [textlocal.com][] is taken form the
		*Runtime Settings* on the neuron. These can be get and set by the neuron operator, via [script][], by using the
		`GetSetting` and `SetSetting` functions. These can also be built into a configuration page, if desired.

		**Note**: Phone numbers starting with `+1555` are considered app-store testing numbers. If using such a number, no
		SMS message is sent. Instead, the account being created is flagged as temporary, for test use only. It is validated
		using the `/ID/TestOTP.md` page, instead of the `/ID/VerifyNumber.ws` resource (see below).

5.	Once a verification code has been sent by the onboarding neuron and received by the user, either via e-mail or SMS, the user
	enters the corresponding code into the app, and the app calls the `/ID/VerifyNumber.ws` resource. The resource compares the
	number provided with the number sent. If there's a mismatch, the login attempt is logged as failed. If they match, it is marked
	as successful.
	
	After validating the phone number, a neuron **Domain** is selected, and returned to the client, together with an **API Key** 
	and **Secret**. This API Key and Secret allows the client to create an account on the neuron identified by the domain, if 
	sufficient accounts are available. Each API key has a limited amount of accounts that can be created using the API Key. The 
	operator needs to increment this amount accordingly, to allow for more users to be onboarded. Having a limit, limits any 
	potential damage to the network, if keys fall into the wrong hands. It also allows the operator to easily identify what 
	malicious accounts have been added, and remove those accordingly, once identified.

	**Note**: The resource can use the country code, purpose and an App identity string to select neuron. This selection is
	implementation specific, and is therefore left outside the scope of this repository. You need to provide the logic to make
	the neuron selection into this resource. Make sure to not check in any API Keys and Secrets into a public repository.
	Check for the string `TBD` in the code, to find where to insert your code. Regions and App names are just examples.

6.	To allow for app and play store testers to get access to the app, for testing purposes, special phone numbers starting with
	`+1555` are permitted. Such phone numbers do not send SMS messages. Instead, they are validated using the `/ID/TestOTP.md`
	resource. It is only possible to create accounts for test use using this method. Such accounts are also limited in time.

7.	The Neuron the client is redirected to in (5) above can validate the onboarding by calling the `ValidateOnboarding.ws`
	resource with the Remote Endpoint of the client, and with any of the e-mail address and/or phone number provided by the
	client to the Neuron. This way, the remote endpoint can automatically validate claims made by the client and assure that
	e-mail addresses and phone numbers provided have been validated and are correct.
	
	**Note**: Validation of phone number and e-mail addresses can only be performed up to 24 hours after successful validation,
	after which the information is removed from memory.

[textlocal.com]: https://textlocal.com/
[script]: https://lab.tagroot.io/Script.md
[Markdown]: https://lab.tagroot.io/Markdown.md
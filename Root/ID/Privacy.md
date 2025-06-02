Title: Privacy policy
Description: Contains the privacy policy for Tag ID and Neuro-Access apps.
Author: Peter Waher
Date: 2021-07-09

Privacy Policy
-----------------

The TAG Digital ID^TM App and the Neuro-Access^TM App will allow you to create a cryptographically secured digital ID. 
These digital IDs can be used for the following pursposes:

* Identify yourself to others, provided you give consent.
* Sign custom requests made by others, with your consent.

The TAG Digital ID^TM App furthermore allows you to:

* Sign smart contracts, with your consent.
* Chat and message with contacts in your roster.
* Interact with protected devices for which you are authorized access.
* Exchange eDaler^TM tokens with others.

When connecting any of the apps to the global federated ID network, you create a network identity of the form `id@domain`, where 
the `id` part is your *account* and the `domain` part is the domain name of the *Trust Provider* you are assigned, The Trust 
Provider is responsible for the proper hosting and management of a Tag Neuron(R) that provides the online services required by 
the app. Any Digital ID you create will be stored encrypted, both in the app, and on the Trust Provider. Any Smart Contracts you 
create will also be stored on the Neuron(R). Any signatures you make on Smart Contracts will be stored, both on the Neuron(R) you 
are connected to, and the Neuron(R) hosting the Smart Contract, if different from yours.

Access to personal data in digital IDs in the federated network, is only granted to others, provided you first give consent 
explicitly. Access to smart contracts is granted, provided any of the parts of the contract give consent. Requesting permission 
to view a Digital ID or Smart Contract explicitly signs the request with the information provided by the Digital ID of the 
requestor, making sure the requestee knows who has made the request. Access to information is also available to operators at 
the Trust Provider, for technical, operational or security purposes. Personal Information is not exported or delivered to third 
parties unless consent has been given explicitly by the corresponding data subjects.

References to Digital IDs or Smart Contracts can be made electronically or optically (for instance using QR codes). References 
are of the form `iotid:GUID@domain` or `iotsc:GUID@domain`, where the URI Scheme `iotid` references a Digital ID, and `iotsc` a 
Smart Contract. `GUID` is a Globally Unique IDentifier, and `domain` is the domainname of the Trust Provider hosting the object. 
When accessing, or requesting access to Digital IDs or Smart Contracts on other domains, the Neurons interconnect, and exchange 
requests in an interoperable manner.

Technical details for how communication, encryption, signatures and validation is performed, is made available by the
[Neuro-Foundation](https://neuro-foundation.io).
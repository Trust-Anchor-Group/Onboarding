if !Request.Encrypted then Forbidden("HTTPS access required.");

IpRec:=IpLocale(Request.RemoteEndPoint);
CountryCode:=IpRec?.CountryCode;
PhoneCode:="";
Waher.Service.IoTBroker.Legal.Identity.PhoneCountryCodes.TryGetShortestCode((CountryCode ?? ""),PhoneCode);

{
	"RemoteEndPoint":Request.RemoteEndPoint,
	"CountryCode":CountryCode,
	"PhoneCode":"+"+PhoneCode,
	"Country":IpRec?.Country,
	"Region":IpRec?.Region,
	"City":IpRec?.City,
	"Latitude":IpRec?.Latitude,
	"Longitude":IpRec?.Longitude
}
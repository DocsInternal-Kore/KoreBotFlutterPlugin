//
//  CountriesList.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 24/01/23.
//  Copyright © 2023 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit
import Foundation
import korebotplugin

var countriesData = "{\"elements\":[{\"country_name\":\"Afghanistan\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/AF.png\",\"code\":\"AF\"},{\"country_name\":\"Albania\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/AL.png\",\"code\":\"AL\"},{\"country_name\":\"Algeria\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/DZ.png\",\"code\":\"DZ\"},{\"country_name\":\"Andorra\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/AD.png\",\"code\":\"AD\"},{\"country_name\":\"Angola\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/AO.png\",\"code\":\"AO\"},{\"country_name\":\"Antigua\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/AG.png\",\"code\":\"AG\"},{\"country_name\":\"Arab\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/SA.png\",\"code\":\"SA\"},{\"country_name\":\"Argentina\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/AR.png\",\"code\":\"AR\"},{\"country_name\":\"Armenia\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/AM.png\",\"code\":\"AM\"},{\"country_name\":\"Australia\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/AU.png\",\"code\":\"AU\"},{\"country_name\":\"Austria\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/AT.png\",\"code\":\"AT\"},{\"country_name\":\"Azerbaijan\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/AZ.png\",\"code\":\"AZ\"},{\"country_name\":\"Bahamas\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/BS.png\",\"code\":\"BS\"},{\"country_name\":\"Bahrain\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/BH.png\",\"code\":\"BH\"},{\"country_name\":\"Bangladesh\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/BD.png\",\"code\":\"BD\"},{\"country_name\":\"Barbados\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/BB.png\",\"code\":\"BB\"},{\"country_name\":\"Belarus\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/BY.png\",\"code\":\"BY\"},{\"country_name\":\"Belgium\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/BE.png\",\"code\":\"BE\"},{\"country_name\":\"Belize\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/BZ.png\",\"code\":\"BZ\"},{\"country_name\":\"Benin\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/BJ.png\",\"code\":\"BJ\"},{\"country_name\":\"Bhutan\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/BT.png\",\"code\":\"BT\"},{\"country_name\":\"Bolivia\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/BO.png\",\"code\":\"BO\"},{\"country_name\":\"Bosnia\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/BA.png\",\"code\":\"BA\"},{\"country_name\":\"Botswana\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/BW.png\",\"code\":\"BW\"},{\"country_name\":\"Brazil\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/BR.png\",\"code\":\"BR\"},{\"country_name\":\"Brunei\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/BN.png\",\"code\":\"BN\"},{\"country_name\":\"Bulgaria\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/BG.png\",\"code\":\"BG\"},{\"country_name\":\"Burkina\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/BF.png\",\"code\":\"BF\"},{\"country_name\":\"Burundi\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/BI.png\",\"code\":\"BI\"},{\"country_name\":\"CAR\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/CF.png\",\"code\":\"CF\"},{\"country_name\":\"Cambodia\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/KH.png\",\"code\":\"KH\"},{\"country_name\":\"Cameroon\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/CM.png\",\"code\":\"CM\"},{\"country_name\":\"Canada\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/CA.png\",\"code\":\"CA\"},{\"country_name\":\"Chad\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/TD.png\",\"code\":\"TD\"},{\"country_name\":\"Chile\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/CL.png\",\"code\":\"CL\"},{\"country_name\":\"China\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/CN.png\",\"code\":\"CN\"},{\"country_name\":\"Colombia\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/CO.png\",\"code\":\"CO\"},{\"country_name\":\"Comoros\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/KM.png\",\"code\":\"KM\"},{\"country_name\":\"Cook\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/CK.png\",\"code\":\"CK\"},{\"country_name\":\"CostaRica\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/CR.png\",\"code\":\"CR\"},{\"country_name\":\"Croatia\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/HR.png\",\"code\":\"HR\"},{\"country_name\":\"Cuba\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/CU.png\",\"code\":\"CU\"},{\"country_name\":\"Cyprus\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/CY.png\",\"code\":\"CY\"},{\"country_name\":\"Czech\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/CZ.png\",\"code\":\"CZ\"},{\"country_name\":\"DR\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/DO.png\",\"code\":\"DO\"},{\"country_name\":\"DRC\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/CD.png\",\"code\":\"CD\"},{\"country_name\":\"Denmark\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/DK.png\",\"code\":\"DK\"},{\"country_name\":\"Djibouti\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/DJ.png\",\"code\":\"DJ\"},{\"country_name\":\"Dominica\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/DM.png\",\"code\":\"DM\"},{\"country_name\":\"EGuinea\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/GQ.png\",\"code\":\"GQ\"},{\"country_name\":\"Ecuador\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/EC.png\",\"code\":\"EC\"},{\"country_name\":\"Egypt\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/EG.png\",\"code\":\"EG\"},{\"country_name\":\"Eritrea\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/ER.png\",\"code\":\"ER\"},{\"country_name\":\"Estonia\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/EE.png\",\"code\":\"EE\"},{\"country_name\":\"Ethiopia\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/ET.png\",\"code\":\"ET\"},{\"country_name\":\"Fiji\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/FJ.png\",\"code\":\"FJ\"},{\"country_name\":\"Finland\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/FI.png\",\"code\":\"FI\"},{\"country_name\":\"France\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/FR.png\",\"code\":\"FR\"},{\"country_name\":\"Gabon\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/GA.png\",\"code\":\"GA\"},{\"country_name\":\"Gambia\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/GM.png\",\"code\":\"GM\"},{\"country_name\":\"Georgia\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/GE.png\",\"code\":\"GE\"},{\"country_name\":\"Germany\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/DE.png\",\"code\":\"DE\"},{\"country_name\":\"Ghana\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/GH.png\",\"code\":\"GH\"},{\"country_name\":\"Greece\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/GR.png\",\"code\":\"GR\"},{\"country_name\":\"Grenada\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/GD.png\",\"code\":\"GD\"},{\"country_name\":\"Guatemala\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/GT.png\",\"code\":\"GT\"},{\"country_name\":\"Guinea\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/GN.png\",\"code\":\"GN\"},{\"country_name\":\"GuineaB\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/GW.png\",\"code\":\"GW\"},{\"country_name\":\"Guyana\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/GY.png\",\"code\":\"GY\"},{\"country_name\":\"Haiti\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/HT.png\",\"code\":\"HT\"},{\"country_name\":\"Honduras\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/HN.png\",\"code\":\"HN\"},{\"country_name\":\"Hungary\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/HU.png\",\"code\":\"HU\"},{\"country_name\":\"Iceland\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/IS.png\",\"code\":\"IS\"},{\"country_name\":\"India\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/IN.png\",\"code\":\"IN\"},{\"country_name\":\"Indonesia\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/ID.png\",\"code\":\"ID\"},{\"country_name\":\"Iran\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/IR.png\",\"code\":\"IR\"},{\"country_name\":\"Iraq\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/IQ.png\",\"code\":\"IQ\"},{\"country_name\":\"Ireland\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/IE.png\",\"code\":\"IE\"},{\"country_name\":\"Israel\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/IL.png\",\"code\":\"IL\"},{\"country_name\":\"Italy\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/IT.png\",\"code\":\"IT\"},{\"country_name\":\"Ivoire\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/CI.png\",\"code\":\"CI\"},{\"country_name\":\"Jamaica\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/JM.png\",\"code\":\"JM\"},{\"country_name\":\"Japan\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/JP.png\",\"code\":\"JP\"},{\"country_name\":\"Jordan\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/JO.png\",\"code\":\"JO\"},{\"country_name\":\"Kazakhstan\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/KZ.png\",\"code\":\"KZ\"},{\"country_name\":\"Kenya\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/KE.png\",\"code\":\"KE\"},{\"country_name\":\"Kiribati\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/KI.png\",\"code\":\"KI\"},{\"country_name\":\"Kosovo\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/KS.png\",\"code\":\"KS\"},{\"country_name\":\"Kuwait\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/KW.png\",\"code\":\"KW\"},{\"country_name\":\"Kyrgyzstan\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/KG.png\",\"code\":\"KG\"},{\"country_name\":\"Lanka\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/LK.png\",\"code\":\"LK\"},{\"country_name\":\"Laos\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/LA.png\",\"code\":\"LA\"},{\"country_name\":\"Latvia\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/LV.png\",\"code\":\"LV\"},{\"country_name\":\"Lebanon\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/LB.png\",\"code\":\"LB\"},{\"country_name\":\"Lesotho\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/LS.png\",\"code\":\"LS\"},{\"country_name\":\"Liberia\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/LR.png\",\"code\":\"LR\"},{\"country_name\":\"Libya\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/LY.png\",\"code\":\"LY\"},{\"country_name\":\"Liechtenstein\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/LI.png\",\"code\":\"LI\"},{\"country_name\":\"Lithuania\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/LT.png\",\"code\":\"LT\"},{\"country_name\":\"Luxembourg\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/LU.png\",\"code\":\"LU\"},{\"country_name\":\"Macedonia\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/MK.png\",\"code\":\"MK\"},{\"country_name\":\"Madagascar\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/MG.png\",\"code\":\"MG\"},{\"country_name\":\"Malawi\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/MW.png\",\"code\":\"MW\"},{\"country_name\":\"Malaysia\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/MY.png\",\"code\":\"MY\"},{\"country_name\":\"Maldives\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/MV.png\",\"code\":\"MV\"},{\"country_name\":\"Mali\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/ML.png\",\"code\":\"ML\"},{\"country_name\":\"Malta\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/MT.png\",\"code\":\"MT\"},{\"country_name\":\"Marshall\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/MH.png\",\"code\":\"MH\"},{\"country_name\":\"Mauritania\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/MR.png\",\"code\":\"MR\"},{\"country_name\":\"Mauritius\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/MU.png\",\"code\":\"MU\"},{\"country_name\":\"Mexico\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/MX.png\",\"code\":\"MX\"},{\"country_name\":\"Micronesia\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/FM.png\",\"code\":\"FM\"},{\"country_name\":\"Moldova\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/MD.png\",\"code\":\"MD\"},{\"country_name\":\"Monaco\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/MC.png\",\"code\":\"MC\"},{\"country_name\":\"Mongolia\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/MN.png\",\"code\":\"MN\"},{\"country_name\":\"Montenegro\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/ME.png\",\"code\":\"ME\"},{\"country_name\":\"Morocco\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/MA.png\",\"code\":\"MA\"},{\"country_name\":\"Mozambique\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/MZ.png\",\"code\":\"MZ\"},{\"country_name\":\"Myanmar\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/MM.png\",\"code\":\"MM\"},{\"country_name\":\"NKorea\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/KP.png\",\"code\":\"KP\"},{\"country_name\":\"NZ\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/NZ.png\",\"code\":\"NZ\"},{\"country_name\":\"Namibia\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/NA.png\",\"code\":\"NA\"},{\"country_name\":\"Nauru\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/NR.png\",\"code\":\"NR\"},{\"country_name\":\"Nepal\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/NP.png\",\"code\":\"NP\"},{\"country_name\":\"Netherlands\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/NL.png\",\"code\":\"NL\"},{\"country_name\":\"Nicaragua\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/NI.png\",\"code\":\"NI\"},{\"country_name\":\"Niger\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/NE.png\",\"code\":\"NE\"},{\"country_name\":\"Nigeria\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/NG.png\",\"code\":\"NG\"},{\"country_name\":\"Niue\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/NU.png\",\"code\":\"NU\"},{\"country_name\":\"Norway\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/NO.png\",\"code\":\"NO\"},{\"country_name\":\"Oman\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/OM.png\",\"code\":\"OM\"},{\"country_name\":\"PGuinea\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/PG.png\",\"code\":\"PG\"},{\"country_name\":\"Pakistan\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/PK.png\",\"code\":\"PK\"},{\"country_name\":\"Palau\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/PW.png\",\"code\":\"PW\"},{\"country_name\":\"Panama\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/PA.png\",\"code\":\"PA\"},{\"country_name\":\"Paraguay\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/PY.png\",\"code\":\"PY\"},{\"country_name\":\"Peru\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/PE.png\",\"code\":\"PE\"},{\"country_name\":\"Philippines\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/PH.png\",\"code\":\"PH\"},{\"country_name\":\"Poland\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/PL.png\",\"code\":\"PL\"},{\"country_name\":\"Portugal\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/PT.png\",\"code\":\"PT\"},{\"country_name\":\"Qatar\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/QA.png\",\"code\":\"QA\"},{\"country_name\":\"RC\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/CG.png\",\"code\":\"CG\"},{\"country_name\":\"RSA\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/ZA.png\",\"code\":\"ZA\"},{\"country_name\":\"Romania\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/RO.png\",\"code\":\"RO\"},{\"country_name\":\"Russia\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/RU.png\",\"code\":\"RU\"},{\"country_name\":\"Rwanda\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/RW.png\",\"code\":\"RW\"},{\"country_name\":\"SKN\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/KN.png\",\"code\":\"KN\"},{\"country_name\":\"SKorea\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/KR.png\",\"code\":\"KR\"},{\"country_name\":\"SL\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/LC.png\",\"code\":\"LC\"},{\"country_name\":\"SM\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/SM.png\",\"code\":\"SM\"},{\"country_name\":\"SSudan\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/SS.png\",\"code\":\"SS\"},{\"country_name\":\"STP\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/ST.png\",\"code\":\"ST\"},{\"country_name\":\"SVG\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/VC.png\",\"code\":\"VC\"},{\"country_name\":\"Sahara\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/EH.png\",\"code\":\"EH\"},{\"country_name\":\"Salvador\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/SV.png\",\"code\":\"SV\"},{\"country_name\":\"Samoa\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/WS.png\",\"code\":\"WS\"},{\"country_name\":\"Senegal\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/SN.png\",\"code\":\"SN\"},{\"country_name\":\"Serbia\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/RS.png\",\"code\":\"RS\"},{\"country_name\":\"Seychelles\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/SC.png\",\"code\":\"SC\"},{\"country_name\":\"Sierra\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/SL.png\",\"code\":\"SL\"},{\"country_name\":\"Singapore\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/SG.png\",\"code\":\"SG\"},{\"country_name\":\"Slovakia\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/SK.png\",\"code\":\"SK\"},{\"country_name\":\"Slovenia\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/SI.png\",\"code\":\"SI\"},{\"country_name\":\"Solomon\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/SB.png\",\"code\":\"SB\"},{\"country_name\":\"Somalia\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/SO.png\",\"code\":\"SO\"},{\"country_name\":\"Spain\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/ES.png\",\"code\":\"ES\"},{\"country_name\":\"Sudan\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/SD.png\",\"code\":\"SD\"},{\"country_name\":\"Suriname\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/SR.png\",\"code\":\"SR\"},{\"country_name\":\"Swaziland\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/SZ.png\",\"code\":\"SZ\"},{\"country_name\":\"Sweden\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/SE.png\",\"code\":\"SE\"},{\"country_name\":\"Switzerland\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/CH.png\",\"code\":\"CH\"},{\"country_name\":\"Syria\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/SY.png\",\"code\":\"SY\"},{\"country_name\":\"Taiwan\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/TW.png\",\"code\":\"TW\"},{\"country_name\":\"Tajikistan\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/TJ.png\",\"code\":\"TJ\"},{\"country_name\":\"Tanzania\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/TZ.png\",\"code\":\"TZ\"},{\"country_name\":\"Thailand\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/TH.png\",\"code\":\"TH\"},{\"country_name\":\"Timor\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/TL.png\",\"code\":\"TL\"},{\"country_name\":\"Togo\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/TG.png\",\"code\":\"TG\"},{\"country_name\":\"Tonga\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/TO.png\",\"code\":\"TO\"},{\"country_name\":\"TrinidadandTobago\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/TT.png\",\"code\":\"TT\"},{\"country_name\":\"Tunisia\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/TN.png\",\"code\":\"TN\"},{\"country_name\":\"Turkey\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/TR.png\",\"code\":\"TR\"},{\"country_name\":\"Turkmenistan\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/TM.png\",\"code\":\"TM\"},{\"country_name\":\"Tuvalu\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/TV.png\",\"code\":\"TV\"},{\"country_name\":\"UAE\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/AE.png\",\"code\":\"AE\"},{\"country_name\":\"UK\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/GB.png\",\"code\":\"GB\"},{\"country_name\":\"USA\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/US.png\",\"code\":\"US\"},{\"country_name\":\"Uganda\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/UG.png\",\"code\":\"UG\"},{\"country_name\":\"Ukraine\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/UA.png\",\"code\":\"UA\"},{\"country_name\":\"Uruguay\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/UY.png\",\"code\":\"UY\"},{\"country_name\":\"Uzbekistan\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/UZ.png\",\"code\":\"UZ\"},{\"country_name\":\"Vanuatu\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/VU.png\",\"code\":\"VU\"},{\"country_name\":\"Vatican\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/VA.png\",\"code\":\"VA\"},{\"country_name\":\"Venezuela\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/VE.png\",\"code\":\"VE\"},{\"country_name\":\"Verde\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/CV.png\",\"code\":\"CV\"},{\"country_name\":\"Vietnam\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/VN.png\",\"code\":\"VN\"},{\"country_name\":\"Yemen\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/YE.png\",\"code\":\"YE\"},{\"country_name\":\"Zambia\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/ZM.png\",\"code\":\"ZM\"},{\"country_name\":\"Zimbabwe\",\"flag\":\"https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/ZW.png\",\"code\":\"ZW\"}]}"
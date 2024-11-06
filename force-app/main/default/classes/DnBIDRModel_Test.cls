@IsTest
public class DnBIDRModel_Test {

	static testMethod void testParse() {
		String json = '{' +
		'    \"Authorization\": \"KH7qCE+6hTcrGouW9JbnSL5rROe67czuUdNRtOkITeY=\",' +
		'    \"transactionDetail\": {' +
		'        \"transactionID\": \"rrt-04b146343b2275455-a-se-17591-702916-2\",' +
		'        \"transactionTimestamp\": \"2020-09-16T06:58:45.069Z\",' +
		'        \"inLanguage\": \"en-US\",' +
		'        \"serviceVersion\": \"1\"' +
		'    },' +
		'    \"inquiryDetail\": {' +
		'        \"name\": \"spectrum\",' +
		'        \"address\": {' +
		'            \"countryISOAlpha2Code\": \"us\"' +
		'        }' +
		'    },' +
		'    \"candidatesMatchedQuantity\": 10,' +
		'    \"matchDataCriteria\": \"Name and Address Lookup\",' +
		'    \"matchCandidates\": [' +
		'        {' +
		'            \"displaySequence\": 1,' +
		'            \"organization\": {' +
		'                \"duns\": \"057192064\",' +
		'                \"dunsControlStatus\": {' +
		'                    \"operatingStatus\": {' +
		'                        \"description\": \"Active\",' +
		'                        \"dnbCode\": 9074' +
		'                    },' +
		'                    \"isMailUndeliverable\": false' +
		'                },' +
		'                \"primaryName\": \"SPECTRUM CORPORATION, THE\",' +
		'                \"telephone\": [' +
		'                    {' +
		'                        \"telephoneNumber\": \"7139446200\",' +
		'                        \"isUnreachable\": false' +
		'                    }' +
		'                ],' +
		'                \"primaryAddress\": {' +
		'                    \"addressCountry\": {' +
		'                        \"isoAlpha2Code\": \"US\",' +
		'                        \"name\": \"United States\"' +
		'                    },' +
		'                    \"addressLocality\": {' +
		'                        \"name\": \"HOUSTON\"' +
		'                    },' +
		'                    \"addressRegion\": {' +
		'                        \"abbreviatedName\": \"TX\"' +
		'                    },' +
		'                    \"postalCode\": \"77075\",' +
		'                    \"postalCodeExtension\": \"3298\",' +
		'                    \"streetAddress\": {' +
		'                        \"line1\": \"10048 EASTHAVEN BLVD\"' +
		'                    }' +
		'                },' +
		'                \"mailingAddress\": {' +
		'                    \"addressCountry\": {' +
		'                        \"isoAlpha2Code\": \"US\",' +
		'                        \"name\": \"United States\"' +
		'                    },' +
		'                    \"postalCode\": \"77275\"' +
		'                },' +
		'                \"mostSeniorPrincipals\": [' +
		'                    {' +
		'                        \"fullName\": \"J B BISHOP\"' +
		'                    }' +
		'                ],' +
		'                \"isStandalone\": false,' +
		'                \"corporateLinkage\": {' +
		'                    \"familytreeRolesPlayed\": [' +
		'                        {' +
		'                            \"description\": \"Parent/Headquarters\",' +
		'                            \"dnbCode\": 9141' +
		'                        }' +
		'                    ]' +
		'                }' +
		'            },' +
		'            \"matchQualityInformation\": {' +
		'                \"confidenceCode\": 6,' +
		'                \"matchGrade\": \"AZZZZZZZFZZ\",' +
		'                \"matchGradeComponentsCount\": 11,' +
		'                \"matchGradeComponents\": [' +
		'                    {' +
		'                        \"componentType\": \"Name\",' +
		'                        \"componentRating\": \"A\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Street Number\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Street Name\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"City\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"State\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"PO Box\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Phone\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Postal Code\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Density\",' +
		'                        \"componentRating\": \"F\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Uniqueness\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Sic\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    }' +
		'                ],' +
		'                \"matchDataProfile\": \"0099999999999999000000989998\",' +
		'                \"matchDataProfileComponentsCount\": 14,' +
		'                \"matchDataProfileComponents\": [' +
		'                    {' +
		'                        \"componentType\": \"Name\",' +
		'                        \"componentValue\": \"00\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Street Number\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Street Name\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"City\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"State\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"PO Box\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Phone\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Postal Code\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"DUNS\",' +
		'                        \"componentValue\": \"00\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"SIC\",' +
		'                        \"componentValue\": \"00\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Density\",' +
		'                        \"componentValue\": \"00\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Uniqueness\",' +
		'                        \"componentValue\": \"98\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"National ID\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"URL\",' +
		'                        \"componentValue\": \"98\"' +
		'                    }' +
		'                ],' +
		'                \"nameMatchScore\": 100' +
		'            }' +
		'        },' +
		'        {' +
		'            \"displaySequence\": 2,' +
		'            \"organization\": {' +
		'                \"duns\": \"150776503\",' +
		'                \"dunsControlStatus\": {' +
		'                    \"operatingStatus\": {' +
		'                        \"description\": \"Active\",' +
		'                        \"dnbCode\": 9074' +
		'                    },' +
		'                    \"isMailUndeliverable\": false' +
		'                },' +
		'                \"primaryName\": \"CHARTER COMMUNICATIONS, INC.\",' +
		'                \"telephone\": [' +
		'                    {' +
		'                        \"telephoneNumber\": \"2039057801\",' +
		'                        \"isUnreachable\": false' +
		'                    }' +
		'                ],' +
		'                \"primaryAddress\": {' +
		'                    \"addressCountry\": {' +
		'                        \"isoAlpha2Code\": \"US\",' +
		'                        \"name\": \"United States\"' +
		'                    },' +
		'                    \"addressLocality\": {' +
		'                        \"name\": \"STAMFORD\"' +
		'                    },' +
		'                    \"addressRegion\": {' +
		'                        \"abbreviatedName\": \"CT\"' +
		'                    },' +
		'                    \"postalCode\": \"06901\",' +
		'                    \"postalCodeExtension\": \"3512\",' +
		'                    \"streetAddress\": {' +
		'                        \"line1\": \"400 ATLANTIC ST\"' +
		'                    }' +
		'                },' +
		'                \"mailingAddress\": {' +
		'                    \"addressCountry\": {' +
		'                        \"isoAlpha2Code\": \"US\",' +
		'                        \"name\": \"United States\"' +
		'                    }' +
		'                },' +
		'                \"mostSeniorPrincipals\": [' +
		'                    {' +
		'                        \"fullName\": \"TOM M RUTLEDGE\"' +
		'                    }' +
		'                ],' +
		'                \"isStandalone\": false' +
		'            },' +
		'            \"matchQualityInformation\": {' +
		'                \"confidenceCode\": 6,' +
		'                \"matchGrade\": \"AZZZZZZZFZZ\",' +
		'                \"matchGradeComponentsCount\": 11,' +
		'                \"matchGradeComponents\": [' +
		'                    {' +
		'                        \"componentType\": \"Name\",' +
		'                        \"componentRating\": \"A\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Street Number\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Street Name\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"City\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"State\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"PO Box\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Phone\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Postal Code\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Density\",' +
		'                        \"componentRating\": \"F\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Uniqueness\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Sic\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    }' +
		'                ],' +
		'                \"matchDataProfile\": \"0299999999999999000000989998\",' +
		'                \"matchDataProfileComponentsCount\": 14,' +
		'                \"matchDataProfileComponents\": [' +
		'                    {' +
		'                        \"componentType\": \"Name\",' +
		'                        \"componentValue\": \"02\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Street Number\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Street Name\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"City\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"State\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"PO Box\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Phone\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Postal Code\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"DUNS\",' +
		'                        \"componentValue\": \"00\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"SIC\",' +
		'                        \"componentValue\": \"00\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Density\",' +
		'                        \"componentValue\": \"00\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Uniqueness\",' +
		'                        \"componentValue\": \"98\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"National ID\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"URL\",' +
		'                        \"componentValue\": \"98\"' +
		'                    }' +
		'                ],' +
		'                \"nameMatchScore\": 100' +
		'            }' +
		'        },' +
		'        {' +
		'            \"displaySequence\": 3,' +
		'            \"organization\": {' +
		'                \"duns\": \"964520717\",' +
		'                \"dunsControlStatus\": {' +
		'                    \"operatingStatus\": {' +
		'                        \"description\": \"Active\",' +
		'                        \"dnbCode\": 9074' +
		'                    },' +
		'                    \"isMailUndeliverable\": false' +
		'                },' +
		'                \"primaryName\": \"SPECTRUM BRANDS LEGACY, INC.\",' +
		'                \"telephone\": [' +
		'                    {' +
		'                        \"telephoneNumber\": \"6082753340\",' +
		'                        \"isUnreachable\": false' +
		'                    }' +
		'                ],' +
		'                \"primaryAddress\": {' +
		'                    \"addressCountry\": {' +
		'                        \"isoAlpha2Code\": \"US\",' +
		'                        \"name\": \"United States\"' +
		'                    },' +
		'                    \"addressLocality\": {' +
		'                        \"name\": \"MIDDLETON\"' +
		'                    },' +
		'                    \"addressRegion\": {' +
		'                        \"abbreviatedName\": \"WI\"' +
		'                    },' +
		'                    \"postalCode\": \"53562\",' +
		'                    \"postalCodeExtension\": \"1431\",' +
		'                    \"streetAddress\": {' +
		'                        \"line1\": \"3001 DEMING WAY\"' +
		'                    }' +
		'                },' +
		'                \"mailingAddress\": {' +
		'                    \"addressCountry\": {' +
		'                        \"isoAlpha2Code\": \"US\",' +
		'                        \"name\": \"United States\"' +
		'                    },' +
		'                    \"postalCode\": \"53562\"' +
		'                },' +
		'                \"mostSeniorPrincipals\": [' +
		'                    {' +
		'                        \"fullName\": \"DAVE M MAURA\"' +
		'                    }' +
		'                ],' +
		'                \"isStandalone\": false,' +
		'                \"corporateLinkage\": {' +
		'                    \"familytreeRolesPlayed\": [' +
		'                        {' +
		'                            \"description\": \"Parent/Headquarters\",' +
		'                            \"dnbCode\": 9141' +
		'                        }' +
		'                    ]' +
		'                }' +
		'            },' +
		'            \"matchQualityInformation\": {' +
		'                \"confidenceCode\": 6,' +
		'                \"matchGrade\": \"AZZZZZZZFZZ\",' +
		'                \"matchGradeComponentsCount\": 11,' +
		'                \"matchGradeComponents\": [' +
		'                    {' +
		'                        \"componentType\": \"Name\",' +
		'                        \"componentRating\": \"A\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Street Number\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Street Name\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"City\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"State\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"PO Box\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Phone\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Postal Code\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Density\",' +
		'                        \"componentRating\": \"F\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Uniqueness\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Sic\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    }' +
		'                ],' +
		'                \"matchDataProfile\": \"0299999999999999000000989998\",' +
		'                \"matchDataProfileComponentsCount\": 14,' +
		'                \"matchDataProfileComponents\": [' +
		'                    {' +
		'                        \"componentType\": \"Name\",' +
		'                        \"componentValue\": \"02\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Street Number\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Street Name\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"City\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"State\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"PO Box\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Phone\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Postal Code\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"DUNS\",' +
		'                        \"componentValue\": \"00\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"SIC\",' +
		'                        \"componentValue\": \"00\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Density\",' +
		'                        \"componentValue\": \"00\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Uniqueness\",' +
		'                        \"componentValue\": \"98\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"National ID\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"URL\",' +
		'                        \"componentValue\": \"98\"' +
		'                    }' +
		'                ],' +
		'                \"nameMatchScore\": 100' +
		'            }' +
		'        },' +
		'        {' +
		'            \"displaySequence\": 4,' +
		'            \"organization\": {' +
		'                \"duns\": \"794347120\",' +
		'                \"dunsControlStatus\": {' +
		'                    \"operatingStatus\": {' +
		'                        \"description\": \"Active\",' +
		'                        \"dnbCode\": 9074' +
		'                    },' +
		'                    \"isMailUndeliverable\": false' +
		'                },' +
		'                \"primaryName\": \"FACILITY CONCESSION SERVICES, INC.\",' +
		'                \"telephone\": [' +
		'                    {' +
		'                        \"telephoneNumber\": \"2813630900\",' +
		'                        \"isUnreachable\": false' +
		'                    }' +
		'                ],' +
		'                \"primaryAddress\": {' +
		'                    \"addressCountry\": {' +
		'                        \"isoAlpha2Code\": \"US\",' +
		'                        \"name\": \"United States\"' +
		'                    },' +
		'                    \"addressLocality\": {' +
		'                        \"name\": \"CONROE\"' +
		'                    },' +
		'                    \"addressRegion\": {' +
		'                        \"abbreviatedName\": \"TX\"' +
		'                    },' +
		'                    \"postalCode\": \"77385\",' +
		'                    \"postalCodeExtension\": \"8958\",' +
		'                    \"streetAddress\": {' +
		'                        \"line1\": \"27433 ROBINSON RD\"' +
		'                    }' +
		'                },' +
		'                \"mailingAddress\": {' +
		'                    \"addressCountry\": {' +
		'                        \"isoAlpha2Code\": \"US\",' +
		'                        \"name\": \"United States\"' +
		'                    },' +
		'                    \"addressLocality\": {' +
		'                        \"name\": \"THE WOODLANDS\"' +
		'                    },' +
		'                    \"addressRegion\": {' +
		'                        \"abbreviatedName\": \"TX\"' +
		'                    },' +
		'                    \"postalCode\": \"77387\",' +
		'                    \"streetAddress\": {' +
		'                        \"line1\": \"PO BOX 7130\"' +
		'                    }' +
		'                },' +
		'                \"mostSeniorPrincipals\": [' +
		'                    {' +
		'                        \"fullName\": \"DAVE H SMALLEY\"' +
		'                    }' +
		'                ],' +
		'                \"isStandalone\": false' +
		'            },' +
		'            \"matchQualityInformation\": {' +
		'                \"confidenceCode\": 6,' +
		'                \"matchGrade\": \"AZZZZZZZFZZ\",' +
		'                \"matchGradeComponentsCount\": 11,' +
		'                \"matchGradeComponents\": [' +
		'                    {' +
		'                        \"componentType\": \"Name\",' +
		'                        \"componentRating\": \"A\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Street Number\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Street Name\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"City\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"State\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"PO Box\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Phone\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Postal Code\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Density\",' +
		'                        \"componentRating\": \"F\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Uniqueness\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Sic\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    }' +
		'                ],' +
		'                \"matchDataProfile\": \"0299999999999999000000980098\",' +
		'                \"matchDataProfileComponentsCount\": 14,' +
		'                \"matchDataProfileComponents\": [' +
		'                    {' +
		'                        \"componentType\": \"Name\",' +
		'                        \"componentValue\": \"02\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Street Number\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Street Name\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"City\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"State\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"PO Box\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Phone\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Postal Code\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"DUNS\",' +
		'                        \"componentValue\": \"00\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"SIC\",' +
		'                        \"componentValue\": \"00\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Density\",' +
		'                        \"componentValue\": \"00\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Uniqueness\",' +
		'                        \"componentValue\": \"98\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"National ID\",' +
		'                        \"componentValue\": \"00\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"URL\",' +
		'                        \"componentValue\": \"98\"' +
		'                    }' +
		'                ],' +
		'                \"nameMatchScore\": 100' +
		'            }' +
		'        },' +
		'        {' +
		'            \"displaySequence\": 5,' +
		'            \"organization\": {' +
		'                \"duns\": \"790888002\",' +
		'                \"dunsControlStatus\": {' +
		'                    \"operatingStatus\": {' +
		'                        \"description\": \"Active\",' +
		'                        \"dnbCode\": 9074' +
		'                    },' +
		'                    \"isMailUndeliverable\": false' +
		'                },' +
		'                \"primaryName\": \"SPECTRUM PHARMACEUTICALS, INC.\",' +
		'                \"telephone\": [' +
		'                    {' +
		'                        \"telephoneNumber\": \"7028356300\",' +
		'                        \"isUnreachable\": false' +
		'                    }' +
		'                ],' +
		'                \"primaryAddress\": {' +
		'                    \"addressCountry\": {' +
		'                        \"isoAlpha2Code\": \"US\",' +
		'                        \"name\": \"United States\"' +
		'                    },' +
		'                    \"addressLocality\": {' +
		'                        \"name\": \"HENDERSON\"' +
		'                    },' +
		'                    \"addressRegion\": {' +
		'                        \"abbreviatedName\": \"NV\"' +
		'                    },' +
		'                    \"postalCode\": \"89052\",' +
		'                    \"postalCodeExtension\": \"5576\",' +
		'                    \"streetAddress\": {' +
		'                        \"line1\": \"11500 S EASTERN AVE STE 240\"' +
		'                    }' +
		'                },' +
		'                \"mailingAddress\": {' +
		'                    \"addressCountry\": {' +
		'                        \"isoAlpha2Code\": \"US\",' +
		'                        \"name\": \"United States\"' +
		'                    }' +
		'                },' +
		'                \"isStandalone\": false' +
		'            },' +
		'            \"matchQualityInformation\": {' +
		'                \"confidenceCode\": 6,' +
		'                \"matchGrade\": \"AZZZZZZZBZZ\",' +
		'                \"matchGradeComponentsCount\": 11,' +
		'                \"matchGradeComponents\": [' +
		'                    {' +
		'                        \"componentType\": \"Name\",' +
		'                        \"componentRating\": \"A\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Street Number\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Street Name\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"City\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"State\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"PO Box\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Phone\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Postal Code\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Density\",' +
		'                        \"componentRating\": \"B\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Uniqueness\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Sic\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    }' +
		'                ],' +
		'                \"matchDataProfile\": \"0299999999999999000000989998\",' +
		'                \"matchDataProfileComponentsCount\": 14,' +
		'                \"matchDataProfileComponents\": [' +
		'                    {' +
		'                        \"componentType\": \"Name\",' +
		'                        \"componentValue\": \"02\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Street Number\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Street Name\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"City\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"State\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"PO Box\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Phone\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Postal Code\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"DUNS\",' +
		'                        \"componentValue\": \"00\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"SIC\",' +
		'                        \"componentValue\": \"00\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Density\",' +
		'                        \"componentValue\": \"00\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Uniqueness\",' +
		'                        \"componentValue\": \"98\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"National ID\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"URL\",' +
		'                        \"componentValue\": \"98\"' +
		'                    }' +
		'                ],' +
		'                \"nameMatchScore\": 100' +
		'            }' +
		'        },' +
		'        {' +
		'            \"displaySequence\": 6,' +
		'            \"organization\": {' +
		'                \"duns\": \"874384514\",' +
		'                \"dunsControlStatus\": {' +
		'                    \"operatingStatus\": {' +
		'                        \"description\": \"Active\",' +
		'                        \"dnbCode\": 9074' +
		'                    },' +
		'                    \"isMailUndeliverable\": false' +
		'                },' +
		'                \"primaryName\": \"SPECTRUM SERVICES, INC.\",' +
		'                \"tradeStyleNames\": [' +
		'                    {' +
		'                        \"name\": \"SPECTRUM\",' +
		'                        \"priority\": 1' +
		'                    }' +
		'                ],' +
		'                \"telephone\": [' +
		'                    {' +
		'                        \"telephoneNumber\": \"7023677705\",' +
		'                        \"isUnreachable\": false' +
		'                    }' +
		'                ],' +
		'                \"primaryAddress\": {' +
		'                    \"addressCountry\": {' +
		'                        \"isoAlpha2Code\": \"US\",' +
		'                        \"name\": \"United States\"' +
		'                    },' +
		'                    \"addressLocality\": {' +
		'                        \"name\": \"LAS VEGAS\"' +
		'                    },' +
		'                    \"addressRegion\": {' +
		'                        \"abbreviatedName\": \"NV\"' +
		'                    },' +
		'                    \"postalCode\": \"89118\",' +
		'                    \"postalCodeExtension\": \"2834\",' +
		'                    \"streetAddress\": {' +
		'                        \"line1\": \"4850 W OQUENDO RD\"' +
		'                    }' +
		'                },' +
		'                \"mailingAddress\": {' +
		'                    \"addressCountry\": {' +
		'                        \"isoAlpha2Code\": \"US\",' +
		'                        \"name\": \"United States\"' +
		'                    }' +
		'                },' +
		'                \"mostSeniorPrincipals\": [' +
		'                    {' +
		'                        \"fullName\": \"CHRISTOPHER  WENER\"' +
		'                    }' +
		'                ],' +
		'                \"isStandalone\": false' +
		'            },' +
		'            \"matchQualityInformation\": {' +
		'                \"confidenceCode\": 6,' +
		'                \"matchGrade\": \"AZZZZZZZFZZ\",' +
		'                \"matchGradeComponentsCount\": 11,' +
		'                \"matchGradeComponents\": [' +
		'                    {' +
		'                        \"componentType\": \"Name\",' +
		'                        \"componentRating\": \"A\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Street Number\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Street Name\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"City\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"State\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"PO Box\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Phone\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Postal Code\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Density\",' +
		'                        \"componentRating\": \"F\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Uniqueness\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Sic\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    }' +
		'                ],' +
		'                \"matchDataProfile\": \"0299999999999999000000980098\",' +
		'                \"matchDataProfileComponentsCount\": 14,' +
		'                \"matchDataProfileComponents\": [' +
		'                    {' +
		'                        \"componentType\": \"Name\",' +
		'                        \"componentValue\": \"02\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Street Number\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Street Name\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"City\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"State\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"PO Box\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Phone\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Postal Code\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"DUNS\",' +
		'                        \"componentValue\": \"00\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"SIC\",' +
		'                        \"componentValue\": \"00\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Density\",' +
		'                        \"componentValue\": \"00\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Uniqueness\",' +
		'                        \"componentValue\": \"98\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"National ID\",' +
		'                        \"componentValue\": \"00\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"URL\",' +
		'                        \"componentValue\": \"98\"' +
		'                    }' +
		'                ],' +
		'                \"nameMatchScore\": 100' +
		'            }' +
		'        },' +
		'        {' +
		'            \"displaySequence\": 7,' +
		'            \"organization\": {' +
		'                \"duns\": \"157294455\",' +
		'                \"dunsControlStatus\": {' +
		'                    \"operatingStatus\": {' +
		'                        \"description\": \"Active\",' +
		'                        \"dnbCode\": 9074' +
		'                    },' +
		'                    \"isMailUndeliverable\": false' +
		'                },' +
		'                \"primaryName\": \"PK SPECTRUM, LLC\",' +
		'                \"telephone\": [' +
		'                    {' +
		'                        \"telephoneNumber\": \"6103540300\",' +
		'                        \"isUnreachable\": false' +
		'                    }' +
		'                ],' +
		'                \"primaryAddress\": {' +
		'                    \"addressCountry\": {' +
		'                        \"isoAlpha2Code\": \"US\",' +
		'                        \"name\": \"United States\"' +
		'                    },' +
		'                    \"addressLocality\": {' +
		'                        \"name\": \"PHOENIXVILLE\"' +
		'                    },' +
		'                    \"addressRegion\": {' +
		'                        \"abbreviatedName\": \"PA\"' +
		'                    },' +
		'                    \"postalCode\": \"19460\",' +
		'                    \"postalCodeExtension\": \"1204\",' +
		'                    \"streetAddress\": {' +
		'                        \"line1\": \"1122 LONGFORD RD\"' +
		'                    }' +
		'                },' +
		'                \"mailingAddress\": {' +
		'                    \"addressCountry\": {' +
		'                        \"isoAlpha2Code\": \"US\",' +
		'                        \"name\": \"United States\"' +
		'                    },' +
		'                    \"postalCode\": \"19460\"' +
		'                },' +
		'                \"mostSeniorPrincipals\": [' +
		'                    {' +
		'                        \"fullName\": \"PEGGY  KELLY\"' +
		'                    }' +
		'                ],' +
		'                \"isStandalone\": false,' +
		'                \"corporateLinkage\": {' +
		'                    \"familytreeRolesPlayed\": [' +
		'                        {' +
		'                            \"description\": \"Parent/Headquarters\",' +
		'                            \"dnbCode\": 9141' +
		'                        }' +
		'                    ]' +
		'                }' +
		'            },' +
		'            \"matchQualityInformation\": {' +
		'                \"confidenceCode\": 6,' +
		'                \"matchGrade\": \"AZZZZZZZFZZ\",' +
		'                \"matchGradeComponentsCount\": 11,' +
		'                \"matchGradeComponents\": [' +
		'                    {' +
		'                        \"componentType\": \"Name\",' +
		'                        \"componentRating\": \"A\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Street Number\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Street Name\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"City\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"State\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"PO Box\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Phone\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Postal Code\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Density\",' +
		'                        \"componentRating\": \"F\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Uniqueness\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Sic\",' +
		'                        \"componentRating\": \"Z\"' +
		'                    }' +
		'                ],' +
		'                \"matchDataProfile\": \"0299999999999999000000989998\",' +
		'                \"matchDataProfileComponentsCount\": 14,' +
		'                \"matchDataProfileComponents\": [' +
		'                    {' +
		'                        \"componentType\": \"Name\",' +
		'                        \"componentValue\": \"02\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Street Number\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Street Name\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"City\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"State\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"PO Box\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Phone\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Postal Code\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"DUNS\",' +
		'                        \"componentValue\": \"00\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"SIC\",' +
		'                        \"componentValue\": \"00\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Density\",' +
		'                        \"componentValue\": \"00\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"Uniqueness\",' +
		'                        \"componentValue\": \"98\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"National ID\",' +
		'                        \"componentValue\": \"99\"' +
		'                    },' +
		'                    {' +
		'                        \"componentType\": \"URL\",' +
		'                        \"componentValue\": \"98\"' +
		'                    }' +
		'                ],' +
		'                \"nameMatchScore\": 100' +
		'            }' +
		'        }' +
		'    ]' +
		'}';
		DnBIDRModel obj = DnBIDRModel.parse(json);
		System.assert(obj != null);
	}
}
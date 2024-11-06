/*-------------------------------------------------------------------------------------------------
  functionality......: This class is called from LWC - stackedBarChart and is used to -
  1. Get the data about how much a list of templates provided from the UI are 
  already booked from the available quota.
 
  2. Get the data about how much a list of templates provided from the UI are 
  available for booking from the available quota.
  -------------------------------------------------------------------------------
  @author............: Atul Sharma
  @created...........: 9th March 2021
  @version...........: 1.0
  ---------------------------------------------------------------------------------------------------
  @author............: 
  @changes...........: 
  vX.X
  YYYY-MM-DD
 
  vX.X 
  YYYY-MM-DD
  ---------------------------------------------------------------------------------------------------
*/
public with sharing class QuerySponsorshipData {

	/*public class BarGraph_Static {
	  public static Decimal barPercentage = 0.5;
	  public static Decimal barThickness = 6;
	  public static Decimal maxBarThickness = 8;
	  public static Decimal minBarLength = 2;
	  public static Boolean fill = true;
	  }*/


	// this map is used to map the number of the month with its text/name value.
	public static map<integer, string> monthNumberNameMap = new map<integer, string> { 1 => 'JAN', 2 => 'FEB', 3 => 'MAR', 4 => 'APR', 5 => 'MAY', 6 => 'JUN',
		7 => 'JUL', 8 => 'AUG', 9 => 'SEP', 10 => 'OCT', 11 => 'NOV', 12 => 'DEC' };

	public static map<String, Integer> monthNameNumberMap = new map<String, Integer> { 'JAN' => 1, 'FEB' => 2, 'MAR' => 3, 'APR' => 4, 'MAY' => 5, 'JUN' => 6,
		'JUL' => 7, 'AUG' => 8, 'SEP' => 9, 'OCT' => 10, 'NOV' => 11, 'DEC' => 12 };
	/*
	 *    This method is called from a LWC - stackedBarChart
	 *    It is used to -
	 *    1. Prepare and Return a wrapper list of data that is going to tell the UI about the booked
	 *       stock percentage of a template(s) choosen from the UI
	 *    2. Prepare and Return a wrapper list of data that is going to tell the UI about the available 
	 *       stock percentage of a template(s) choosen from the UI
	 *    @author     Atul Kumar
	 *    @param      List<string>           List of Ids of the template reords choosen from the UI
	 *    @return     List<DataSet>          Wrapper list to show the booking percentage on UI
	 */
	@AuraEnabled(cacheable = true)
	public static List<wrapDataSets> getData(List<string> choosenTemplates, string choosenRadioOption, Date startDate, Date endDate) {
		try {
			system.debug('choosenTemplates=' + choosenTemplates + '--choosenRadioOption=' + choosenRadioOption + '-- startDate' + startDate + '-- endDate' + endDate);
			if (choosenRadioOption == 'Booked' || choosenRadioOption == null)
			return getBookedSponsorship(choosenTemplates, startDate, endDate);
			else
			return getAvailableSponsorship(choosenTemplates, startDate, endDate);
		}
		catch(exception ex) { system.debug(ex.getStackTraceString()); throw ex; }

	}

	/*
	 *    This method is called from a LWC - getData
	 *    It is used to -
	 *    1. Prepare and Return a wrapper list of data that is going to tell the UI about the booked
	 *       stock percentage of a template(s) choosen from the UI
	 *    
	 *    @author     Atul Kumar
	 *    @param      List<string>           List of Ids of the template reords choosen from the UI
	 *    @return     List<DataSet>          Wrapper list to show the booking percentage on UI
	 */
	public static List<wrapDataSets> getBookedSponsorship(List<string> choosenTemplates, Date startDate, Date endDate) {

		System.debug('choosenTemplates=' + choosenTemplates);


		List<wrapDataSets> dataSetList = new List<wrapDataSets> ();
		Set<string> inputTemplateNames = new Set<string> ();
		//Dates entered by user for Graph population
		Integer graphStartMonth = startDate.month();
		Integer graphEndMonth = endDate.month();
		Integer graphStartYear = startDate.year();
		Integer graphEndYear = endDate.year();
		// Dates for template start and end dates
		integer startmonth;
		integer endMonth;
		integer startYear;
		integer endYear;

		Map<integer, integer> tempMap;
		Map<string, decimal> templateMonthBookingPercentMap;
		Map<string, Map<integer, integer>> bookingmMap = new Map<string, Map<integer, integer>> ();
		List<Templates__c> templateList = new List<Templates__c> ();
		string currentYear = string.valueOf(system.today().year());
		List<String> barColors = new List<String> { '#033F63', '#EC91D8', '#DA7422', '#59C3C3' };

		templateList = [Select End_Date__c, Id, Name, OwnerId, Total_Quantity__c, Start_Date__c, Template_Inventory__c, RecordType.Name,
		(select id, name, Start_Date__c, End_Date__c from Sponsorship_Bookings__r), (Select Id, Available_Quantity__c, Total_quantity__c, Booked_Inventory__c,Inventory_Type__c from Template_Inventories__r)
		                from Templates__c where id in :choosenTemplates and Total_Quantity__c != null ORDER BY Start_Date__c desc];

		for (Templates__c templateRecord : templateList) {
			system.debug('templateRecord=' + templateRecord);
			Map<Integer, Map<integer, integer>> yearMonthValMap = new Map<Integer, Map<integer, integer>> ();
			Map<Integer, Map<integer, integer>> bookingYearMonthValMap = new Map<Integer, Map<integer, integer>> ();
			tempMap = new Map<integer, integer> ();
			if (templateRecord.RecordType.Name == 'National') {
				Map<integer, integer> bookingtempMap = new Map<integer, integer> ();
				startmonth = templateRecord.Start_Date__c.month();
				endMonth = templateRecord.End_Date__c.month();
				startYear = templateRecord.Start_Date__c.year();
				endYear = templateRecord.End_Date__c.year();
				Integer updatedEndYear = graphStartYear;
				Date newEndDate = templateRecord.Start_Date__c;
				system.debug('date Data=' + startmonth + ' - ' + endMonth + ' - ' + startYear + ' - ' + endYear);
				//Check the data for Booking

				for (Sponsorship_Booking__c sponBookRec : templateRecord.Sponsorship_Bookings__r)
				{
					system.debug('sponBookRec=' + sponBookRec);
					Integer bookingStartMonth = sponBookRec.Start_Date__c.month();
					Integer bookingEndMonth = sponBookRec.End_Date__c.month();
					Integer bookingStartYear = sponBookRec.Start_Date__c.year();
					Integer bookingEndYear = sponBookRec.End_Date__c.year();
					Integer updatedBookingEndYear = bookingStartYear;
					integer loopEnd = bookingStartYear == bookingEndYear ? bookingEndMonth : 12;
					for (integer i = bookingStartMonth; i <= loopEnd; i++)
					{
						If (updatedBookingEndYear <= bookingEndYear)
						{
							if (!bookingYearMonthValMap.containsKey(updatedBookingEndYear))
							{
								bookingtempMap.put(i, 1);
								bookingYearMonthValMap.put(updatedBookingEndYear, bookingtempMap);
								System.debug('bookingYearMonthValMap ' + updatedBookingEndYear + bookingtempMap);
							}
							else
							{
								bookingtempMap = bookingYearMonthValMap.get(updatedBookingEndYear);
								if (bookingtempMap.containsKey(i))
								bookingtempMap.put(i, bookingtempMap.get(i) + 1);
								else
								bookingtempMap.put(i, 1);
								bookingYearMonthValMap.put(updatedBookingEndYear, bookingtempMap);

								// Check if the loop is on the last month of the year. If so then reset all the variables.
								if (updatedBookingEndYear == bookingEndYear && (i == bookingEndMonth))
								{
									System.debug('i ' + i);
									i = 13;
									break;

								}

								System.debug('bookingYearMonthValMap  ' + i + ' ' + bookingYearMonthValMap);
							}
							// Check if the loop is on the last month of the year. If so then reset all the variables.
							if (i == 12 && updatedBookingEndYear<bookingEndYear)
							{
								i = 0;
								updatedBookingEndYear++;
								bookingtempMap = new Map<integer, integer> ();
							}
						}
					}

				}
				if (endYear >= startYear)
				{
					Integer i = 0;
					for (i = (updatedEndYear == startYear ? startmonth : 1); i <= 12; i++)
					{

						If (updatedEndYear <= endYear)
						{

							if (!yearMonthValMap.containsKey(updatedEndYear))
							{
								tempmap.put(i, 1);
								yearMonthValMap.put(updatedEndYear, tempMap);
								System.debug('yearMonthValMap ' + updatedEndYear + tempMap);
							}
							else
							{
								tempMap = yearMonthValMap.get(updatedEndYear);
								if (tempmap.containsKey(i))
								tempmap.put(i, tempMap.get(i) + 1);
								else
								tempmap.put(i, 1);
								yearMonthValMap.put(updatedEndYear, tempMap);

								// Check if the loop is on the last month of the year. If so then reset all the variables.
								if (updatedEndYear == endYear && (i == endMonth))
								{
									System.debug('i ' + i);
									i = 13;
									break;

								}
								// Check if the loop is on the last month of the year. If so then reset all the variables.

								System.debug('yearMonthValMap  ' + i + ' ' + yearMonthValMap);
							}
							if (i == 12 && updatedEndYear<endYear)
							{
								i = 0;
								updatedEndYear++;
								tempMap = new Map<integer, integer> ();
							}
						}
					}
					newEndDate.addMonths(1);
				}
				else
				{
					while (endmonth >= startmonth) {
						if (tempmap.keySet().contains(startmonth))
						tempmap.put(startmonth, tempMap.get(startmonth) + 1);
						else
						tempmap.put(startmonth, 1);
						startmonth += 1;
					}
					yearMonthValMap.put(startYear, tempMap);
				}
				system.debug('tempMap=' + tempMap.keySet());
				bookingmMap.put(templateRecord.Name, tempmap);

				//List for Amounts and month
				for (Template_Inventory__c temp : templateRecord.Template_Inventories__r) {
					List<barAmntWrapper> barAmntList = new List<barAmntWrapper> ();
					if (bookingmMap != null && bookingmMap.keyset().size()> 0) {
						tempMap = bookingmMap.get(templateRecord.Name);
						templateMonthBookingPercentMap = new map<string, decimal> ();

						for (integer yearVal : yearMonthValMap.KeySet())
						{
							if (yearVal <= graphEndYear)
							{
								for (integer monthVal : yearMonthValMap.get(yearVal).KeySet())
								{
									templateMonthBookingPercentMap.put(monthNumberNameMap.get(monthVal) + '/' + yearVal,
									((yearMonthValMap.get(yearVal).get(monthVal) / templateRecord.Total_Quantity__c) * 100));
									system.debug('monthVal =' + monthVal + ' graphEndMonth =' + graphEndMonth + ' yearVal =' + yearVal + ' graphEndYear =' + graphEndYear + ' graphStartMonth=  ' + graphStartMonth + ' graphStartYear=  ' + graphStartYear);
									//2020 == 2020
									if (yearVal >= graphStartYear)
									{
										if (yearVal<graphEndYear)
										{
											if ((monthVal >= graphStartMonth && yearVal == graphStartYear))
											{
												barAmntWrapper barAmntObj = new barAmntWrapper();
												if (bookingYearMonthValMap.containsKey(yearVal))
												{ 
													if (bookingYearMonthValMap.get(yearVal).containsKey(monthVal))
													{
														barAmntObj.y = Integer.valueOf(( temp.Booked_Inventory__c / temp.Total_Quantity__c) * 100);
													}
													else
													barAmntObj.y = 0;
												}
												else
												barAmntObj.y = 0;

												barAmntObj.x = monthNumberNameMap.get(monthVal) + '/' + yearVal;
												barAmntList.add(barAmntObj);
												System.debug(' barAmntObj ' + barAmntObj);
											}
											else if ((yearVal> graphStartYear))
											{
												barAmntWrapper barAmntObj = new barAmntWrapper();
												if (bookingYearMonthValMap.containsKey(yearVal))
												{
													if (bookingYearMonthValMap.get(yearVal).containsKey(monthVal))
													{
														barAmntObj.y = Integer.valueOf((temp.Booked_Inventory__c / temp.Total_Quantity__c) * 100);
													}
													else
													barAmntObj.y = 0;
												}
												else
												barAmntObj.y = 0;

												barAmntObj.x = monthNumberNameMap.get(monthVal) + '/' + yearVal;
												barAmntList.add(barAmntObj);
												System.debug(' barAmntObj ' + barAmntObj);
											}

										}
										else if (yearVal == graphStartYear && graphStartYear == graphEndYear)
										{
											if ((monthVal >= graphStartMonth && monthVal <= graphEndMonth))
											{
												barAmntWrapper barAmntObj = new barAmntWrapper();
												if (bookingYearMonthValMap.containsKey(yearVal))
												{
													if (bookingYearMonthValMap.get(yearVal).containsKey(monthVal))
													{
														barAmntObj.y = Integer.valueOf((temp.Booked_Inventory__c / temp.Total_Quantity__c) * 100);
													}
													else
													barAmntObj.y = 0;
												}
												else
												barAmntObj.y = 0;

												barAmntObj.x = monthNumberNameMap.get(monthVal) + '/' + yearVal;
												barAmntList.add(barAmntObj);
												System.debug(' barAmntObj ' + barAmntObj);
											}
										}
									}

									if ((monthVal <= graphEndMonth) && (yearVal> graphStartYear && yearVal == graphEndYear))
									{
										barAmntWrapper barAmntObj = new barAmntWrapper();
										if (bookingYearMonthValMap.containsKey(yearVal))
										{
											if (bookingYearMonthValMap.get(yearVal).containsKey(monthVal))
											{
												barAmntObj.y = Integer.valueOf((temp.Booked_Inventory__c / temp.Total_Quantity__c) * 100);
											}
											else
											barAmntObj.y = 0;
										}
										else
										barAmntObj.y = 0;

										barAmntObj.x = monthNumberNameMap.get(monthVal) + '/' + yearVal;
										barAmntList.add(barAmntObj);
										System.debug(' barAmntObj ' + barAmntObj);
									}
								}
							}
						}
						dataSetList.add(new wrapDataSets(templateRecord.Name + ' : ' + temp.Inventory_Type__c + '-:' + String.valueOf(temp.Total_Quantity__c), barAmntList, true, 0.5, 6.0, 8.0, 2.0, '#BA55D3', '#BA55D3', '#BA55D3', '#BA55D3'));
					}
				}
			}
			else {
				Map<integer, integer> bookingtempMap = new Map<integer, integer> ();
				startmonth = templateRecord.Start_Date__c.month();
				endMonth = templateRecord.End_Date__c.month();
				startYear = templateRecord.Start_Date__c.year();
				endYear = templateRecord.End_Date__c.year();
				Integer updatedEndYear = graphStartYear;
				Date newEndDate = templateRecord.Start_Date__c;
				system.debug('date Data=' + startmonth + ' - ' + endMonth + ' - ' + startYear + ' - ' + endYear);
				//Check the data for Booking

				for (Sponsorship_Booking__c sponBookRec : templateRecord.Sponsorship_Bookings__r)
				{
					system.debug('sponBookRec=' + sponBookRec);
					Integer bookingStartMonth = sponBookRec.Start_Date__c.month();
					Integer bookingEndMonth = sponBookRec.End_Date__c.month();
					Integer bookingStartYear = sponBookRec.Start_Date__c.year();
					Integer bookingEndYear = sponBookRec.End_Date__c.year();
					Integer updatedBookingEndYear = bookingStartYear;
					integer loopEnd = bookingStartYear == bookingEndYear ? bookingEndMonth : 12;
					for (integer i = bookingStartMonth; i <= loopEnd; i++)
					{
						If (updatedBookingEndYear <= bookingEndYear)
						{
							if (!bookingYearMonthValMap.containsKey(updatedBookingEndYear))
							{
								bookingtempMap.put(i, 1);
								bookingYearMonthValMap.put(updatedBookingEndYear, bookingtempMap);
								System.debug('bookingYearMonthValMap ' + updatedBookingEndYear + bookingtempMap);
							}
							else
							{
								bookingtempMap = bookingYearMonthValMap.get(updatedBookingEndYear);
								if (bookingtempMap.containsKey(i))
								bookingtempMap.put(i, bookingtempMap.get(i) + 1);
								else
								bookingtempMap.put(i, 1);
								bookingYearMonthValMap.put(updatedBookingEndYear, bookingtempMap);

								// Check if the loop is on the last month of the year. If so then reset all the variables.
								if (updatedBookingEndYear == bookingEndYear && (i == bookingEndMonth))
								{
									System.debug('i ' + i);
									i = 13;
									break;

								}

								System.debug('bookingYearMonthValMap  ' + i + ' ' + bookingYearMonthValMap);
							}
							// Check if the loop is on the last month of the year. If so then reset all the variables.
							if (i == 12 && updatedBookingEndYear<bookingEndYear)
							{
								i = 0;
								updatedBookingEndYear++;
								bookingtempMap = new Map<integer, integer> ();
							}
						}
					}

				}
				if (endYear >= startYear)
				{
					Integer i = 0;
					for (i = (updatedEndYear == startYear ? startmonth : 1); i <= 12; i++)
					{

						If (updatedEndYear <= endYear)
						{

							if (!yearMonthValMap.containsKey(updatedEndYear))
							{
								tempmap.put(i, 1);
								yearMonthValMap.put(updatedEndYear, tempMap);
								System.debug('yearMonthValMap ' + updatedEndYear + tempMap);
							}
							else
							{
								tempMap = yearMonthValMap.get(updatedEndYear);
								if (tempmap.containsKey(i))
								tempmap.put(i, tempMap.get(i) + 1);
								else
								tempmap.put(i, 1);
								yearMonthValMap.put(updatedEndYear, tempMap);

								// Check if the loop is on the last month of the year. If so then reset all the variables.
								if (updatedEndYear == endYear && (i == endMonth))
								{
									System.debug('i ' + i);
									i = 13;
									break;

								}
								// Check if the loop is on the last month of the year. If so then reset all the variables.

								System.debug('yearMonthValMap  ' + i + ' ' + yearMonthValMap);
							}
							if (i == 12 && updatedEndYear<endYear)
							{
								i = 0;
								updatedEndYear++;
								tempMap = new Map<integer, integer> ();
							}
						}
					}
					newEndDate.addMonths(1);
				}
				else
				{
					while (endmonth >= startmonth) {
						if (tempmap.keySet().contains(startmonth))
						tempmap.put(startmonth, tempMap.get(startmonth) + 1);
						else
						tempmap.put(startmonth, 1);
						startmonth += 1;
					}
					yearMonthValMap.put(startYear, tempMap);
				}
				system.debug('tempMap=' + tempMap.keySet());
				bookingmMap.put(templateRecord.Name, tempmap);

				//List for Amounts and month
				List<barAmntWrapper> barAmntList = new List<barAmntWrapper> ();
				if (bookingmMap != null && bookingmMap.keyset().size()> 0) {
					tempMap = bookingmMap.get(templateRecord.Name);
					templateMonthBookingPercentMap = new map<string, decimal> ();

					for (integer yearVal : yearMonthValMap.KeySet())
					{
						if (yearVal <= graphEndYear)
						{
							for (integer monthVal : yearMonthValMap.get(yearVal).KeySet())
							{
								templateMonthBookingPercentMap.put(monthNumberNameMap.get(monthVal) + '/' + yearVal,
								((yearMonthValMap.get(yearVal).get(monthVal) / templateRecord.Total_Quantity__c) * 100));
								system.debug('monthVal =' + monthVal + ' graphEndMonth =' + graphEndMonth + ' yearVal =' + yearVal + ' graphEndYear =' + graphEndYear + ' graphStartMonth=  ' + graphStartMonth + ' graphStartYear=  ' + graphStartYear);
								//2020 == 2020
								if (yearVal >= graphStartYear)
								{
									if (yearVal<graphEndYear)
									{
										if ((monthVal >= graphStartMonth && yearVal == graphStartYear))
										{
											barAmntWrapper barAmntObj = new barAmntWrapper();
											if (bookingYearMonthValMap.containsKey(yearVal))
											{
												if (bookingYearMonthValMap.get(yearVal).containsKey(monthVal))
												{
													barAmntObj.y = Integer.valueOf(((bookingYearMonthValMap.get(yearVal).get(monthVal)) / templateRecord.Total_Quantity__c) * 100);
												}
												else
												barAmntObj.y = 0;
											}
											else
											barAmntObj.y = 0;

											barAmntObj.x = monthNumberNameMap.get(monthVal) + '/' + yearVal;
											barAmntList.add(barAmntObj);
											System.debug(' barAmntObj ' + barAmntObj);
										}
										else if ((yearVal> graphStartYear))
										{
											barAmntWrapper barAmntObj = new barAmntWrapper();
											if (bookingYearMonthValMap.containsKey(yearVal))
											{
												if (bookingYearMonthValMap.get(yearVal).containsKey(monthVal))
												{
													barAmntObj.y = Integer.valueOf(((bookingYearMonthValMap.get(yearVal).get(monthVal)) / templateRecord.Total_Quantity__c) * 100);
												}
												else
												barAmntObj.y = 0;
											}
											else
											barAmntObj.y = 0;

											barAmntObj.x = monthNumberNameMap.get(monthVal) + '/' + yearVal;
											barAmntList.add(barAmntObj);
											System.debug(' barAmntObj ' + barAmntObj);
										}

									}
									else if (yearVal == graphStartYear && graphStartYear == graphEndYear)
									{
										if ((monthVal >= graphStartMonth && monthVal <= graphEndMonth))
										{
											barAmntWrapper barAmntObj = new barAmntWrapper();
											if (bookingYearMonthValMap.containsKey(yearVal))
											{
												if (bookingYearMonthValMap.get(yearVal).containsKey(monthVal))
												{
													barAmntObj.y = Integer.valueOf(((bookingYearMonthValMap.get(yearVal).get(monthVal)) / templateRecord.Total_Quantity__c) * 100);
												}
												else
												barAmntObj.y = 0;
											}
											else
											barAmntObj.y = 0;

											barAmntObj.x = monthNumberNameMap.get(monthVal) + '/' + yearVal;
											barAmntList.add(barAmntObj);
											System.debug(' barAmntObj ' + barAmntObj);
										}
									}
								}

								if ((monthVal <= graphEndMonth) && (yearVal> graphStartYear && yearVal == graphEndYear))
								{
									barAmntWrapper barAmntObj = new barAmntWrapper();
									if (bookingYearMonthValMap.containsKey(yearVal))
									{
										if (bookingYearMonthValMap.get(yearVal).containsKey(monthVal))
										{
											barAmntObj.y = Integer.valueOf(((bookingYearMonthValMap.get(yearVal).get(monthVal)) / templateRecord.Total_Quantity__c) * 100);
										}
										else
										barAmntObj.y = 0;
									}
									else
									barAmntObj.y = 0;

									barAmntObj.x = monthNumberNameMap.get(monthVal) + '/' + yearVal;
									barAmntList.add(barAmntObj);
									System.debug(' barAmntObj ' + barAmntObj);
								}
							}
						}
					}
					dataSetList.add(new wrapDataSets(templateRecord.Name + ' - Qty-:' + String.valueOf(templateRecord.Total_Quantity__c), barAmntList, true, 0.5, 6.0, 8.0, 2.0, '#BA55D3', '#BA55D3', '#BA55D3', '#BA55D3'));
				}
			}
		}
		for (Integer i = 0; i<dataSetList.size(); i++)
		{
			dataSetList[i].backgroundColor = barColors[i];
			System.debug(' startDate.month() ' + startDate.month());
			System.debug(' startDate.month() ' + startDate.month());
			System.debug(' monthNameNumberMap Month' + monthNameNumberMap.get(dataSetList[i].data[0].x.split('/') [0]));
			System.debug(' monthNameNumberMap Year' + dataSetList[i].data[0].x.split('/') [1]);
			Date sDate = Date.newInstance(Integer.valueOf(dataSetList[i].data[0].x.split('/') [1]), Integer.valueOf(monthNameNumberMap.get(dataSetList[i].data[0].x.split('/') [0])), 15);

			System.debug(' sDate.month() ' + sDate);
			System.debug(' Months Between' + sDate.monthsBetween(startDate));
			if (sDate.monthsBetween(startDate) == - 1)
			{
				List<barAmntWrapper> barAmntList = new List<barAmntWrapper> ();
				barAmntWrapper barAmntObj = new barAmntWrapper();
				barAmntObj.y = 0;
				barAmntObj.x = monthNumberNameMap.get(startDate.month()) + '/' + String.valueOf(startDate.year());
				barAmntList.add(barAmntObj);
				barAmntList.addAll(dataSetList[i].data);
				dataSetList[i].data = barAmntList;
				//dataSetList[i].data[0].y = 0;
			}
			else
			{
				dataSetList[i].data[0].y = 0;
			}
			Integer MonthDataSize = dataSetList[i].data.size();
			Date eDate = Date.newInstance(Integer.valueOf(dataSetList[i].data[MonthDataSize - 1].x.split('/') [1]), Integer.valueOf(monthNameNumberMap.get(dataSetList[i].data[MonthDataSize - 1].x.split('/') [0])), 15);
			System.debug(' startDate.month() ' + endDate.month());
			System.debug(' monthNameNumberMap' + monthNameNumberMap.get(dataSetList[i].data[MonthDataSize - 1].x.split('/') [0]));

			if (eDate.monthsBetween(endDate) == 1)
			{
				List<barAmntWrapper> barAmntList = new List<barAmntWrapper> ();
				barAmntWrapper barAmntObj = new barAmntWrapper();
				barAmntObj.y = 0;
				barAmntObj.x = monthNumberNameMap.get(endDate.month()) + '/' + String.valueOf(endDate.year());

				barAmntList.addAll(dataSetList[i].data);
				barAmntList.add(barAmntObj);
				dataSetList[i].data = barAmntList;
				//dataSetList[i].data[0].y = 0;
			}
			else
			{
				dataSetList[i].data[MonthDataSize - 1].y = 0;
			}

			System.debug('datalist border color ' + dataSetList[i].backgroundColor);
		}
		System.debug('dataSetList=' + dataSetList);
		return dataSetList;
	}
	public static List<wrapDataSets> getAvailableSponsorship(List<string> choosenTemplates, Date startDate, Date endDate) {

		System.debug('choosenTemplates=' + choosenTemplates);

		List<wrapDataSets> dataSetList = new List<wrapDataSets> ();
		Set<string> inputTemplateNames = new Set<string> ();
		//Dates entered by user for Graph population
		Integer graphStartMonth = startDate.month();
		Integer graphEndMonth = endDate.month();
		Integer graphStartYear = startDate.year();
		Integer graphEndYear = endDate.year();
		// Dates for template start and end dates
		integer startmonth;
		integer endMonth;
		integer startYear;
		integer endYear;
		Map<integer, integer> tempMap;
		Map<string, decimal> templateMonthBookingPercentMap;
		Map<string, Map<integer, integer>> bookingmMap = new Map<string, Map<integer, integer>> ();
		List<Templates__c> templateList = new List<Templates__c> ();
		string currentYear = string.valueOf(system.today().year());
		List<String> barColors = new List<String> { '#033F63', '#EC91D8', '#DA7422', '#59C3C3' };

		templateList = [Select End_Date__c, Id, Name, OwnerId, Total_Quantity__c, Start_Date__c, Template_Inventory__c, RecordType.Name,
		(select id, name, Start_Date__c, End_Date__c from Sponsorship_Bookings__r), (Select Id, Available_Quantity__c, Total_quantity__c, Inventory_Type__c from Template_Inventories__r)
		                from Templates__c where id in :choosenTemplates and Total_Quantity__c != null ORDER BY Start_Date__c desc];

		System.debug('@@ tempList ' + templateList);

		for (Templates__c templateRecord : templateList) {
			system.debug('templateRecord=' + templateRecord);
			Map<Integer, Map<integer, integer>> yearMonthValMap = new Map<Integer, Map<integer, integer>> ();
			Map<Integer, Map<integer, integer>> bookingYearMonthValMap = new Map<Integer, Map<integer, integer>> ();
			tempMap = new Map<integer, integer> ();
			Map<integer, integer> bookingtempMap = new Map<integer, integer> ();
			if (templateRecord.RecordType.Name == 'National') {
				startmonth = templateRecord.Start_Date__c.month();
				//Date starttemplateDate = date.newInstance(templateRecord.Start_Date__c);
				endMonth = templateRecord.End_Date__c.month();
				startYear = templateRecord.Start_Date__c.year();
				endYear = templateRecord.End_Date__c.year();
				Integer updatedEndYear = startYear;
				Date newEndDate = templateRecord.Start_Date__c;
				system.debug('date Data=' + startmonth + ' - ' + endMonth + ' - ' + startYear + ' - ' + endYear);
				//Check the data for Booking

				System.debug('Booking National Template');

				for (Sponsorship_Booking__c sponBookRec : templateRecord.Sponsorship_Bookings__r)
				{
					system.debug('@@ sponBookRec=' + sponBookRec);
					Integer bookingStartMonth = sponBookRec.Start_Date__c.month();
					Integer bookingEndMonth = sponBookRec.End_Date__c.month();
					Integer bookingStartYear = sponBookRec.Start_Date__c.year();
					Integer bookingEndYear = sponBookRec.End_Date__c.year();
					Integer updatedBookingEndYear = bookingStartYear;
					integer loopEnd = bookingStartYear == bookingEndYear ? bookingEndMonth : 12;
					for (integer i = bookingStartMonth; i <= loopEnd; i++)
					{
						bookingtempMap = new Map<integer, integer> ();
						If (updatedBookingEndYear <= bookingEndYear)
						{
							if (!bookingYearMonthValMap.containsKey(updatedBookingEndYear))
							{
								bookingtempMap.put(i, 1);
								bookingYearMonthValMap.put(updatedBookingEndYear, bookingtempMap);
								System.debug('bookingYearMonthValMap ' + updatedBookingEndYear + bookingtempMap);
							}
							else
							{

								bookingtempMap = bookingYearMonthValMap.get(updatedBookingEndYear);
								System.debug('bookingYearMonthValMap1 ' + updatedBookingEndYear + bookingtempMap);
								if (bookingtempMap.containsKey(i))
								bookingtempMap.put(i, bookingtempMap.get(i) + 1);
								else
								bookingtempMap.put(i, 1);
								bookingYearMonthValMap.put(updatedBookingEndYear, bookingtempMap);

								// Check if the loop is on the last month of the year. If so then reset all the variables.
								if (updatedBookingEndYear == bookingEndYear && (i == bookingEndMonth))
								{
									System.debug('i ' + i);
									i = 13;
									break;

								}
								// Check if the loop is on the last month of the year. If so then reset all the variables.

								System.debug('bookingYearMonthValMap2  ' + i + ' ' + bookingYearMonthValMap);
							}
							if (i == 12 && updatedBookingEndYear<bookingEndYear)
							{
								i = 0;
								updatedBookingEndYear++;
								bookingtempMap = new Map<integer, integer> ();
							}
						}
					}

				}

				if (endYear >= startYear)
				{
					for (integer i = startmonth; i <= 12; i++)
					{

						If (updatedEndYear <= endYear)
						{

							if (!yearMonthValMap.containsKey(updatedEndYear))
							{
								tempmap.put(i, 1);
								yearMonthValMap.put(updatedEndYear, tempMap);
								System.debug('yearMonthValMap ' + updatedEndYear + tempMap);
							}
							else
							{
								tempMap = yearMonthValMap.get(updatedEndYear);
								if (tempmap.containsKey(i))
								tempmap.put(i, tempMap.get(i) + 1);
								else
								tempmap.put(i, 1);
								yearMonthValMap.put(updatedEndYear, tempMap);

								// Check if the loop is on the last month of the year. If so then reset all the variables.
								if (updatedEndYear == endYear && (i == endMonth))
								{
									System.debug('i ' + i);
									i = 13;
									break;

								}
								// Check if the loop is on the last month of the year. If so then reset all the variables.

								System.debug('yearMonthValMap  ' + i + ' ' + yearMonthValMap);
							}
							if (i == 12 && updatedEndYear<endYear)
							{
								i = 0;
								updatedEndYear++;
								tempMap = new Map<integer, integer> ();
							}
						}
					}
					newEndDate.addMonths(1);
				}
				else
				{
					while (endmonth >= startmonth) {
						if (tempmap.keySet().contains(startmonth))
						tempmap.put(startmonth, tempMap.get(startmonth) + 1);
						else
						tempmap.put(startmonth, 1);
						startmonth += 1;
					}
				}
				system.debug('tempMap=' + tempMap.keySet());
				bookingmMap.put(templateRecord.Name, tempmap);


				//List for Amounts and month
				for (Template_Inventory__c temp : templateRecord.Template_Inventories__r) {
					List<barAmntWrapper> barAmntList = new List<barAmntWrapper> ();
					if (bookingmMap != null && bookingmMap.keyset().size()> 0) {
						tempMap = bookingmMap.get(templateRecord.Name);
						templateMonthBookingPercentMap = new map<string, decimal> ();
						System.debug('Available Quantity: ' + temp.Available_Quantity__c);
						for (integer yearVal : yearMonthValMap.KeySet())
						{
							if (yearVal <= graphEndYear)
							{
								for (integer monthVal : yearMonthValMap.get(yearVal).KeySet())
								{
									//templateMonthBookingPercentMap.put(monthNumberNameMap.get(monthVal) + '/' + yearVal,
									//((yearMonthValMap.get(yearVal).get(monthVal) / temp.Available_Quantity__c) * 100));
									system.debug('monthVal =' + monthVal + ' graphEndMonth =' + graphEndMonth + ' yearVal =' + yearVal + ' graphEndYear =' + graphEndYear + ' graphStartMonth=  ' + graphStartMonth + ' graphStartYear=  ' + graphStartYear);
									if (yearVal >= graphStartYear)
									{

										if (yearVal<graphEndYear)
										{
											if ((monthVal >= graphStartMonth && yearVal == graphStartYear))
											{
												barAmntWrapper barAmntObj = new barAmntWrapper();
												if (bookingYearMonthValMap.containsKey(yearVal))
												{
													if (bookingYearMonthValMap.get(yearVal).containsKey(monthVal))
													{
														barAmntObj.y = Integer.valueOf(((temp.Available_Quantity__c) / temp.Total_quantity__c) * 100);
													}
													else
													barAmntObj.y = 100;
												}
												else
												barAmntObj.y = 100;

												barAmntObj.x = monthNumberNameMap.get(monthVal) + '/' + yearVal;
												barAmntList.add(barAmntObj);
												System.debug(' barAmntObj ' + barAmntObj);

											}
											else if ((yearVal> graphStartYear))
											{
												barAmntWrapper barAmntObj = new barAmntWrapper();
												if (bookingYearMonthValMap.containsKey(yearVal))
												{
													if (bookingYearMonthValMap.get(yearVal).containsKey(monthVal))
													{
														barAmntObj.y = Integer.valueOf(((temp.Available_Quantity__c) / temp.Total_quantity__c) * 100);
													}
													else
													barAmntObj.y = 100;
												}
												else
												barAmntObj.y = 100;

												barAmntObj.x = monthNumberNameMap.get(monthVal) + '/' + yearVal;
												barAmntList.add(barAmntObj);
												System.debug(' barAmntObj ' + barAmntObj);
											}
										}
										else if (yearVal == graphStartYear && graphStartYear == graphEndYear)
										{
											if ((monthVal >= graphStartMonth && monthVal <= graphEndMonth))
											{
												barAmntWrapper barAmntObj = new barAmntWrapper();
												if (bookingYearMonthValMap.containsKey(yearVal))
												{
													if (bookingYearMonthValMap.get(yearVal).containsKey(monthVal))
													{
														barAmntObj.y = Integer.valueOf(((temp.Available_Quantity__c) / temp.Total_quantity__c) * 100);
													}
													else
													barAmntObj.y = 100;
												}
												else
												barAmntObj.y = 100;

												barAmntObj.x = monthNumberNameMap.get(monthVal) + '/' + yearVal;
												barAmntList.add(barAmntObj);
												System.debug(' barAmntObj ' + barAmntObj);

											}
										}
									}
									if ((monthVal <= graphEndMonth) && (yearVal> graphStartYear && yearVal == graphEndYear))
									{
										barAmntWrapper barAmntObj = new barAmntWrapper();
										if (bookingYearMonthValMap.containsKey(yearVal))
										{
											if (bookingYearMonthValMap.get(yearVal).containsKey(monthVal))
											{
												barAmntObj.y = Integer.valueOf(((temp.Available_Quantity__c) / temp.Total_quantity__c) * 100);
											}
											else
											barAmntObj.y = 100;
										}
										else
										barAmntObj.y = 100;

										barAmntObj.x = monthNumberNameMap.get(monthVal) + '/' + yearVal;
										barAmntList.add(barAmntObj);
										System.debug(' barAmntObj ' + barAmntObj);

									}
								}
							}
						}
						dataSetList.add(new wrapDataSets(templateRecord.Name + ' : ' + temp.Inventory_Type__c + '-:' + String.valueOf(temp.Total_Quantity__c), barAmntList, true, 0.5, 6.0, 8.0, 2.0, '#BA55D3', '#BA55D3', '#BA55D3', '#BA55D3'));
						System.debug('National Template dataList: ' + dataSetList);
					}
				}
			}
			else {
				startmonth = templateRecord.Start_Date__c.month();
				//Date starttemplateDate = date.newInstance(templateRecord.Start_Date__c);
				endMonth = templateRecord.End_Date__c.month();
				startYear = templateRecord.Start_Date__c.year();
				endYear = templateRecord.End_Date__c.year();
				Integer updatedEndYear = startYear;
				Date newEndDate = templateRecord.Start_Date__c;
				system.debug('date Data=' + startmonth + ' - ' + endMonth + ' - ' + startYear + ' - ' + endYear);
				//Check the data for Booking

				for (Sponsorship_Booking__c sponBookRec : templateRecord.Sponsorship_Bookings__r)
				{
					system.debug('sponBookRec=' + sponBookRec);
					Integer bookingStartMonth = sponBookRec.Start_Date__c.month();
					Integer bookingEndMonth = sponBookRec.End_Date__c.month();
					Integer bookingStartYear = sponBookRec.Start_Date__c.year();
					Integer bookingEndYear = sponBookRec.End_Date__c.year();
					Integer updatedBookingEndYear = bookingStartYear;
					integer loopEnd = bookingStartYear == bookingEndYear ? bookingEndMonth : 12;
					for (integer i = bookingStartMonth; i <= loopEnd; i++)
					{
						bookingtempMap = new Map<integer, integer> ();
						If (updatedBookingEndYear <= bookingEndYear)
						{
							if (!bookingYearMonthValMap.containsKey(updatedBookingEndYear))
							{
								bookingtempMap.put(i, 1);
								bookingYearMonthValMap.put(updatedBookingEndYear, bookingtempMap);
								System.debug('bookingYearMonthValMap ' + updatedBookingEndYear + bookingtempMap);
							}
							else
							{

								bookingtempMap = bookingYearMonthValMap.get(updatedBookingEndYear);
								System.debug('bookingYearMonthValMap1 ' + updatedBookingEndYear + bookingtempMap);
								if (bookingtempMap.containsKey(i))
								bookingtempMap.put(i, bookingtempMap.get(i) + 1);
								else
								bookingtempMap.put(i, 1);
								bookingYearMonthValMap.put(updatedBookingEndYear, bookingtempMap);

								// Check if the loop is on the last month of the year. If so then reset all the variables.
								if (updatedBookingEndYear == bookingEndYear && (i == bookingEndMonth))
								{
									System.debug('i ' + i);
									i = 13;
									break;

								}
								// Check if the loop is on the last month of the year. If so then reset all the variables.

								System.debug('bookingYearMonthValMap2  ' + i + ' ' + bookingYearMonthValMap);
							}
							if (i == 12 && updatedBookingEndYear<bookingEndYear)
							{
								i = 0;
								updatedBookingEndYear++;
								bookingtempMap = new Map<integer, integer> ();
							}
						}
					}

				}

				if (endYear >= startYear)
				{
					for (integer i = startmonth; i <= 12; i++)
					{

						If (updatedEndYear <= endYear)
						{

							if (!yearMonthValMap.containsKey(updatedEndYear))
							{
								tempmap.put(i, 1);
								yearMonthValMap.put(updatedEndYear, tempMap);
								System.debug('yearMonthValMap ' + updatedEndYear + tempMap);
							}
							else
							{
								tempMap = yearMonthValMap.get(updatedEndYear);
								if (tempmap.containsKey(i))
								tempmap.put(i, tempMap.get(i) + 1);
								else
								tempmap.put(i, 1);
								yearMonthValMap.put(updatedEndYear, tempMap);

								// Check if the loop is on the last month of the year. If so then reset all the variables.
								if (updatedEndYear == endYear && (i == endMonth))
								{
									System.debug('i ' + i);
									i = 13;
									break;

								}
								// Check if the loop is on the last month of the year. If so then reset all the variables.

								System.debug('yearMonthValMap  ' + i + ' ' + yearMonthValMap);
							}
							if (i == 12 && updatedEndYear<endYear)
							{
								i = 0;
								updatedEndYear++;
								tempMap = new Map<integer, integer> ();
							}
						}
					}
					newEndDate.addMonths(1);
				}
				else
				{
					while (endmonth >= startmonth) {
						if (tempmap.keySet().contains(startmonth))
						tempmap.put(startmonth, tempMap.get(startmonth) + 1);
						else
						tempmap.put(startmonth, 1);
						startmonth += 1;
					}
				}
				system.debug('tempMap=' + tempMap.keySet());
				bookingmMap.put(templateRecord.Name, tempmap);

				//List for Amounts and month
				List<barAmntWrapper> barAmntList = new List<barAmntWrapper> ();
				if (bookingmMap != null && bookingmMap.keyset().size()> 0) {
					tempMap = bookingmMap.get(templateRecord.Name);
					templateMonthBookingPercentMap = new map<string, decimal> ();

					for (integer yearVal : yearMonthValMap.KeySet())
					{
						if (yearVal <= graphEndYear)
						{
							for (integer monthVal : yearMonthValMap.get(yearVal).KeySet())
							{
								templateMonthBookingPercentMap.put(monthNumberNameMap.get(monthVal) + '/' + yearVal,
								((yearMonthValMap.get(yearVal).get(monthVal) / templateRecord.Total_Quantity__c) * 100));
								system.debug('monthVal =' + monthVal + ' graphEndMonth =' + graphEndMonth + ' yearVal =' + yearVal + ' graphEndYear =' + graphEndYear + ' graphStartMonth=  ' + graphStartMonth + ' graphStartYear=  ' + graphStartYear);
								if (yearVal >= graphStartYear)
								{

									if (yearVal<graphEndYear)
									{
										if ((monthVal >= graphStartMonth && yearVal == graphStartYear))
										{
											barAmntWrapper barAmntObj = new barAmntWrapper();
											if (bookingYearMonthValMap.containsKey(yearVal))
											{
												if (bookingYearMonthValMap.get(yearVal).containsKey(monthVal))
												{
													barAmntObj.y = Integer.valueOf(((templateRecord.Total_Quantity__c - bookingYearMonthValMap.get(yearVal).get(monthVal)) / templateRecord.Total_Quantity__c) * 100);
												}
												else
												barAmntObj.y = 100;
											}
											else
											barAmntObj.y = 100;

											barAmntObj.x = monthNumberNameMap.get(monthVal) + '/' + yearVal;
											barAmntList.add(barAmntObj);
											System.debug(' barAmntObj ' + barAmntObj);

										}
										else if ((yearVal> graphStartYear))
										{
											barAmntWrapper barAmntObj = new barAmntWrapper();
											if (bookingYearMonthValMap.containsKey(yearVal))
											{
												if (bookingYearMonthValMap.get(yearVal).containsKey(monthVal))
												{
													barAmntObj.y = Integer.valueOf(((templateRecord.Total_Quantity__c - bookingYearMonthValMap.get(yearVal).get(monthVal)) / templateRecord.Total_Quantity__c) * 100);
												}
												else
												barAmntObj.y = 100;
											}
											else
											barAmntObj.y = 100;

											barAmntObj.x = monthNumberNameMap.get(monthVal) + '/' + yearVal;
											barAmntList.add(barAmntObj);
											System.debug(' barAmntObj ' + barAmntObj);
										}
									}
									else if (yearVal == graphStartYear && graphStartYear == graphEndYear)
									{
										if ((monthVal >= graphStartMonth && monthVal <= graphEndMonth))
										{
											barAmntWrapper barAmntObj = new barAmntWrapper();
											if (bookingYearMonthValMap.containsKey(yearVal))
											{
												if (bookingYearMonthValMap.get(yearVal).containsKey(monthVal))
												{
													barAmntObj.y = Integer.valueOf(((templateRecord.Total_Quantity__c - bookingYearMonthValMap.get(yearVal).get(monthVal)) / templateRecord.Total_Quantity__c) * 100);
												}
												else
												barAmntObj.y = 100;
											}
											else
											barAmntObj.y = 100;

											barAmntObj.x = monthNumberNameMap.get(monthVal) + '/' + yearVal;
											barAmntList.add(barAmntObj);
											System.debug(' barAmntObj ' + barAmntObj);

										}
									}
								}
								if ((monthVal <= graphEndMonth) && (yearVal> graphStartYear && yearVal == graphEndYear))
								{
									barAmntWrapper barAmntObj = new barAmntWrapper();
									if (bookingYearMonthValMap.containsKey(yearVal))
									{
										if (bookingYearMonthValMap.get(yearVal).containsKey(monthVal))
										{
											barAmntObj.y = Integer.valueOf(((templateRecord.Total_Quantity__c - bookingYearMonthValMap.get(yearVal).get(monthVal)) / templateRecord.Total_Quantity__c) * 100);
										}
										else
										barAmntObj.y = 100;
									}
									else
									barAmntObj.y = 100;

									barAmntObj.x = monthNumberNameMap.get(monthVal) + '/' + yearVal;
									barAmntList.add(barAmntObj);
									System.debug(' barAmntObj ' + barAmntObj);

								}
							}
						}
					}
					dataSetList.add(new wrapDataSets(templateRecord.Name + ' - Qty-:' + String.valueOf(templateRecord.Total_Quantity__c), barAmntList, true, 0.5, 6.0, 8.0, 2.0, '#BA55D3', '#BA55D3', '#BA55D3', '#BA55D3'));
				}
			}
		}

		//for (Integer i = 0; i<dataSetList.size(); i++) {
		//dataSetList[i].backgroundColor = barColors[i];
		//Integer MonthDataSize = dataSetList[i].data.size();
		//if((startDate.month() - monthNameNumberMap.get(dataSetList[i].data[0].x.split('/')[0])) != -1 )
		//{
		//dataSetList[i].data[0].y = 0;
		//}
		//if((endDate.month() - monthNameNumberMap.get(dataSetList[i].data[MonthDataSize - 1].x.split('/')[0])) != -1 )
		//{
		//dataSetList[i].data[MonthDataSize - 1].y = 0;
		//}
		////dataSetList[i].data[MonthDataSize - 1].y = 0;
		//System.debug('datalist border color ' + dataSetList[i].backgroundColor);
		//}

		for (Integer i = 0; i<dataSetList.size(); i++)
		{
			dataSetList[i].backgroundColor = barColors[i];
			System.debug(' startDate.month() ' + startDate.month());
			System.debug(' startDate.month() ' + startDate.month());
			System.debug(' dataSetList[i].data[0] ' + dataSetList[i].data[0]);
			System.debug(' monthNameNumberMap Month' + monthNameNumberMap.get(dataSetList[i].data[0].x.split('/') [0]));
			System.debug(' monthNameNumberMap Year' + dataSetList[i].data[0].x.split('/') [1]);
			Date sDate = Date.newInstance(Integer.valueOf(dataSetList[i].data[0].x.split('/') [1]), Integer.valueOf(monthNameNumberMap.get(dataSetList[i].data[0].x.split('/') [0])), 15);

			System.debug(' sDate.month() ' + sDate);
			System.debug(' Months Between' + sDate.monthsBetween(startDate));
			if (sDate.monthsBetween(startDate) == - 1)
			{
				List<barAmntWrapper> barAmntList = new List<barAmntWrapper> ();
				barAmntWrapper barAmntObj = new barAmntWrapper();
				barAmntObj.y = 0;
				barAmntObj.x = monthNumberNameMap.get(startDate.month()) + '/' + String.valueOf(startDate.year());
				barAmntList.add(barAmntObj);
				barAmntList.addAll(dataSetList[i].data);
				dataSetList[i].data = barAmntList;
				//dataSetList[i].data[0].y = 0;
			}
			else
			{
				dataSetList[i].data[0].y = 0;
			}
			Integer MonthDataSize = dataSetList[i].data.size();
			Date eDate = Date.newInstance(Integer.valueOf(dataSetList[i].data[MonthDataSize - 1].x.split('/') [1]), Integer.valueOf(monthNameNumberMap.get(dataSetList[i].data[MonthDataSize - 1].x.split('/') [0])), 15);
			System.debug(' startDate.month() ' + endDate.month());
			System.debug(' monthNameNumberMap' + monthNameNumberMap.get(dataSetList[i].data[MonthDataSize - 1].x.split('/') [0]));

			if (eDate.monthsBetween(endDate) == 1)
			{
				List<barAmntWrapper> barAmntList = new List<barAmntWrapper> ();
				barAmntWrapper barAmntObj = new barAmntWrapper();
				barAmntObj.y = 0;
				barAmntObj.x = monthNumberNameMap.get(endDate.month()) + '/' + String.valueOf(endDate.year());

				barAmntList.addAll(dataSetList[i].data);
				barAmntList.add(barAmntObj);
				dataSetList[i].data = barAmntList;
				//dataSetList[i].data[0].y = 0;
			}
			else
			{
				dataSetList[i].data[MonthDataSize - 1].y = 0;
			}

			System.debug('datalist border color ' + dataSetList[i].backgroundColor);
		}
		System.debug('dataSetList=' + dataSetList);
		return dataSetList;
	}
	/*
	 *    This method is called from a LWC - getData
	 *    It is used to -
	 *    1. Prepare and Return a wrapper list of data that is going to tell the UI about the available 
	 *       stock percentage of a template(s) choosen from the UI
	 *    
	 *    @author     Atul Kumar
	 *    @param      List<string>           List of Ids of the template reords choosen from the UI
	 *    @return     List<DataSet>          Wrapper list to show the booking percentage on UI
	 */
	public static List<DataSet> getavailableBoooking(List<string> choosenTemplates) {
		List<DataSet> dataSetList = new List<DataSet> ();
		return dataSetList;
	}

	/*
	 *    This method is called from a LWC - getData
	 *    It is used to -
	 *    1. Prepare and Return a wrapper list of data that is going to tell the UI about the available 
	 *       stock percentage of a template(s) choosen from the UI
	 *    
	 *    @author     Atul Kumar
	 *    @param      List<string>           List of Ids of the template reords choosen from the UI
	 *    @return     List<DataSet>          Wrapper list to show the booking percentage on UI
	 */
	//public Map<Integer,Map<integer,integer>> calculateYearMonthMap(List<string> choosenTemplates){
	//List<DataSet> dataSetList                    = new List<DataSet>();
	//return dataSetList;
	//}



	//Wrapper for Bar Graph amounts binding
	public class barAmntWrapper {
		@AuraEnabled public Decimal y { get; set; }
		@AuraEnabled public String x { get; set; }
		public barAmntWrapper() {
			this.y = 0;
			this.x = '';
		}
	}

	//Wrapper class to store the data for booked and available quota of a template.
	public class DataSet {
		@AuraEnabled public String templateName { get; set; }
		@AuraEnabled public List<barAmntWrapper> barAmntList { get; set; }

		public DataSet(String templateName, List<barAmntWrapper> barAmntList) {
			this.templateName = templateName;
			this.barAmntList = barAmntList;
		}
	}

	public class wrapDataSets {
		@AuraEnabled
		public Boolean fill { get; set; }
		@AuraEnabled
		public Double barPercentage { get; set; }
		@AuraEnabled
		public Double barThickness { get; set; }
		@AuraEnabled
		public Double maxBarThickness { get; set; }
		@AuraEnabled
		public Double minBarLength { get; set; }
		@AuraEnabled
		public String backgroundColor { get; set; }
		@AuraEnabled
		public String borderColor { get; set; }
		@AuraEnabled
		public String pointBackgroundColor { get; set; }
		@AuraEnabled
		public String pointBorderColor { get; set; }
		@AuraEnabled public String label { get; set; }
		@AuraEnabled public List<barAmntWrapper> data { get; set; }


		public wrapDataSets(String label, List<barAmntWrapper> data, Boolean fill, Decimal barPercentage, Decimal barThickness, Decimal maxBarThickness, Decimal minBarLength, String backgroundColor, String borderColor, String pointBackgroundColor, String pointBorderColor) {
			this.label = label;
			this.data = data;
			this.fill = fill;
			this.barPercentage = barPercentage;
			this.barThickness = barThickness;
			this.maxBarThickness = maxBarThickness;
			this.minBarLength = minBarLength;
			this.backgroundColor = backgroundColor;
			this.borderColor = borderColor;
			this.pointBackgroundColor = pointBackgroundColor;
			this.pointBorderColor = pointBorderColor;
			//monthYear = new List<String> ();
			//Integer currentYear = System.Today().year();
			//System.debug('List of Months nad Year ' + monthYear);
		}

	}
}
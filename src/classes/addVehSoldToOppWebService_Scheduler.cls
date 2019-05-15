/**
 * Created by admin on 2019-03-22.
 *
 * addVehSoldToOppWebService_Scheduler  sch2 = new addVehSoldToOppWebService_Scheduler(); //Schedule apex class name
system.schedule('Vehicles Sold Update', addVehSoldToOppWebService_Scheduler.CRON_EXP, sch2); //system method to schedule apex class



addVehSoldToOppWebService_Scheduler.startDate = Date.valueOf('2019-03-25');
addVehSoldToOppWebService_Scheduler.endDate = Date.valueOf('2019-03-25');
addVehSoldToOppWebService_Scheduler.CRON_EXP = '0 0 13 * 3 ? 2019';
addVehSoldToOppWebService_Scheduler  sch2 = new addVehSoldToOppWebService_Scheduler();
system.schedule('Vehicles Sold Update', addVehSoldToOppWebService_Scheduler.CRON_EXP, sch2);

 */

global with sharing class addVehSoldToOppWebService_Scheduler implements Schedulable {

    public static String CRON_EXP = '0 0 10 * * ?'; // runs everyday at 10:00am.
    public static Date startDate;
    public static Date endDate;

    private static addVehSoldToOppWebService av;

    global void execute(SchedulableContext SC) {
        startDate = (startDate == null ? Date.today().addDays(-31) : startDate);
        endDate = (endDate == null ? Date.today().addDays(-1) : endDate);

        processing(startDate, endDate);
    }

    @Future(Callout=true)
    public static void processing(Date startDate, Date endDate) {
        av = new addVehSoldToOppWebService(startDate, endDate);
        if (!Test.isRunningTest()) {
            av.vehicleSoldProcess(av.getToken());  //testing already in Test2.  Causing issues with callout for test3...
        }
    }
}
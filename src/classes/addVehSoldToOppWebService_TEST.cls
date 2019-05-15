/**
 * Created by admin on 2019-03-22.
 */

@IsTest
public with sharing class addVehSoldToOppWebService_TEST {

    /*

    HAD TO CREATED DATA LOCALLY TO AVOID CALLOUT ISSUES IN SCHEDULABLE TEST METHOD.

    @TestSetup static void setup() {

        List<Integer> portalId = new List<Integer>{167718, 168199, 169656, 172301, 172230, 172243, 172198, 171569, 170402};
        TestDataFactory_Opportunity.makeCreditApplications(9, true, portalId);

    } */

    @IsTest static void test1GetToken() {

        TestDataFactory_Opportunity.makeCreditApplications(9, true );

        Test.setMock(HttpCalloutMock.class, new addVehSoldToOppWebService_Token_MOCK());

        Test.startTest();

        addVehSoldToOppWebService av = new addVehSoldToOppWebService(Date.today().addDays(-1), Date.today().addDays(-1) ); // yesterday.
        Map<String, Object> token = (Map<String, Object>) JSON.deserializeUntyped(av.getToken());

        Test.stopTest();

        System.assert(token.get('access_token') != null);
        System.assert(token.get('expiration') != null );

    }

    @IsTest static void test2ProcessVehicles() {
        
        TestDataFactory_Opportunity.makeCreditApplications(9, true);

        String token='{"access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9","expiration": "2299-11-26T13:37:42Z"}';
        Test.setMock(HttpCalloutMock.class, new addVehSoldToOppWebService_MOCK());

        Test.startTest();

        addVehSoldToOppWebService av = new addVehSoldToOppWebService(Date.today().addDays(-1), Date.today().addDays(-1) ); // yesterday.
        Integer sz = av.vehicleSoldProcess(token);

        Test.stopTest();

        System.assertEquals(9, sz, 'There should be nine (9) records in test');
        List<Opportunity> opps = [SELECT Id, Podium_Ready__c FROM Opportunity WHERE Podium_Ready__c = TRUE];
        System.assertEquals(9, opps.size(), 'All records should be flagged ready for Podium');

    }

    @IsTest static void test3Scheduler() {

        Test.setMock(HttpCalloutMock.class, new addVehSoldToOppWebService_Token_MOCK());
        Test.startTest();

        // Schedule the test job
        addVehSoldToOppWebService_Scheduler.startDate = Date.today().addDays(-1);
        addVehSoldToOppWebService_Scheduler.endDate = Date.today().addDays(-1);
        String jobId = System.schedule('testVehiclesSoldScheduler', addVehSoldToOppWebService_Scheduler.CRON_EXP,
                new addVehSoldToOppWebService_Scheduler());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger WHERE Id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(addVehSoldToOppWebService_Scheduler.CRON_EXP, ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();
    }
}
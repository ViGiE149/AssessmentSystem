/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

/**
 *
 * @author Admin
 */
package testsClass;

public class Test {
    private int testId;
    private String testName;
    private int durationHours;
    private int durationMinutes;
    private String testDate;
    private String latestPin;

    // Constructor, Getters, and Setters
    public Test(int testId, String testName, int durationHours, int durationMinutes, String testDate, String latestPin) {
        this.testId = testId;
        this.testName = testName;
        this.durationHours = durationHours;
        this.durationMinutes = durationMinutes;
        this.testDate = testDate;
        this.latestPin = latestPin;
    }

    public int getTestId() {
        return testId;
    }

    public String getTestName() {
        return testName;
    }

    public int getDurationHours() {
        return durationHours;
    }

    public int getDurationMinutes() {
        return durationMinutes;
    }

    public String getTestDate() {
        return testDate;
    }

    public String getLatestPin() {
        return latestPin;
    }
}

package seakers.vassar.problems.Scheduling;

import seakers.vassar.BaseParams;

import java.util.HashMap;

public abstract class SchedulingParams extends BaseParams {

    // Instruments
    protected int[] schedule;
    protected int numMiss;
    protected HashMap<Integer, Integer> scheduleIndexes;

    public SchedulingParams(String resourcesPath, String problemName, String mode, String name, String runMode){
        super(resourcesPath, problemName, mode, name, runMode);
    }

    @Override
    public void init(){

        super.init();

        numMiss = schedule.length;

        scheduleIndexes = new HashMap<>();

        for (int i = 0; i < numMiss; i++) {
            scheduleIndexes.put(schedule[i], i);
        }
    }

    public void setSchedule(int[] schedule){
        this.schedule = schedule;
        this.init();
    }

    public int[] getSchedule(){
        return this.schedule;
    }

    public int getNumMiss(){
        return this.numMiss;
    }

    public HashMap<Integer, Integer> getScheduleIndexes() {
        return scheduleIndexes;
    }




}

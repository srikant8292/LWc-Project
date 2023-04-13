import { LightningElement } from 'lwc';
import AlarmClockAssets from '@salesforce/resourceUrl/AlarmClockAssets'

export default class AlarmClockApp extends LightningElement {
    clockImage=AlarmClockAssets + '/AlarmClockAssets/clock.png';

    ringTone= new Audio(AlarmClockAssets + '/AlarmClockAssets/Clocksound.mp3');
    currentTime='';

    hourSelected;
    minSelected;
    meriSelected;

    isAlarmTriggered=false;

    alarmTime;
    isAlarmSet=false;

    hourOptions=[];
    minOptions=[];
    meridian=['AM','PM'];

    get isAllField(){
        return !(this.hourSelected && this.minSelected && this.meriSelected);
    }

    get getShakeImage(){
        return this.isAlarmTriggered ? 'shake':'';
    }
    connectedCallback(){
        this.currentTimeHandler();
        this.createHourOptions();
        this.createMinutesOptions();
    }

    currentTimeHandler(){
        setInterval(()=>{
            let dateTime=new Date();
            let hour=dateTime.getHours();
            let min=dateTime.getMinutes();
            let sec=dateTime.getSeconds();
    
            let ampm="AM";
    
            if(hour==0){
                hour=12;
            }
            else if(hour >12){
                hour=hour-12;
                ampm="PM"
            }
    
            hour=hour<10 ? "0"+hour :hour;
            min=min<10 ? "0"+min :min;
            sec=sec<10 ? "0"+sec :sec;
            
            this.currentTime=`${hour} ${min} ${sec} ${ampm}`;

            if(this.alarmTime === `${hour} : ${min} ${ampm}`){
                console.log('Alarm Triggered......');

                this.isAlarmTriggered=true;

                this.ringTone.play();
                this.ringTone.loop=true;
            }
        },1000);
        
    }

    createHourOptions(){
        for(let i=1;i<=12;i++){
            let val= i<10 ? "0"+i : i;
            this.hourOptions.push(val);
        }
    }
    createMinutesOptions(){
        for(let i=0;i<=59;i++){
            let val= i<10 ? "0"+i : i;
            this.minOptions.push(val);
        }
    }

    changeHandler(event){
        console.log(event.target.value);
        console.log(event.target.name);

        let val=event.target.value;
        let name=event.target.name;

        if(name==='hours'){
            this.hourSelected=val;
        }
        else if(name==='minutes'){
            this.minSelected=val;
        }
        else if(name==='meris'){
            this.meriSelected=val;
        }
        else{

        }

        // console.log("this.hourSelected"+this.hourSelected);
        // console.log("this.minSelected"+this.minSelected);
        // console.log("this.meriSelected"+this.meriSelected);

    }

    setAlarmHandler(){
      this.alarmTime=`${this.hourSelected} : ${this.minSelected} ${this.meriSelected}`;
      this.isAlarmSet=true;
    }

    clearAlarmHandler(){
        this.alarmTime='';
        this.isAlarmSet=false;
        this.hourSelected='';
       this.minSelected='';
        this.meriSelected='';

        this.ringTone.pause();

        this.isAlarmTriggered=false;

      let selectElement= this.template.querySelectorAll('select');

      Array.from(selectElement).forEach(ele=>{
        ele.value='';
      })

    }
}
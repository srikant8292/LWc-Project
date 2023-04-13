import { LightningElement } from 'lwc';

export default class BmiCalculator extends LightningElement {
    height='';
    weight='';
    bmiValue='';

    result='';


    inputHandler(event){
        const {name,value}=event.target;

        if(name === "height"){
            this.height=value;
        }

        if(name === "weight"){
            this.weight=value;
        }
    }

    submitHandler(event){
        event.preventDefault();
        console.log("height"+this.height);
        console.log("weight"+this.weight);
        this.calculate();
    }
    calculate(){
      let height=Number(this.height)/100;
      let bmi=Number(this.weight)/(height * height);

      this.bmiValue=Number(bmi.toFixed(2));

      if(this.bmiValue <18.5){
       this.result='You are under weight';
      }
      else if(this.bmiValue >= 18.5 && this.bmiValue <= 24.9){
        this.result ='You are healthy';
      } 
      else if(this.bmiValue >= 25 && this.bmiValue <= 29.9){
        this.result ='You are Over Weight';
      } 
      else if(this.bmiValue >= 30){
        this.result ='You are Obese';
      }
    }

    recalculate(){
        this.height='';
    this.weight='';
    this.bmiValue='';
       this.result='';
    }
}
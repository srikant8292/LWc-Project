import { LightningElement } from 'lwc';
import {countryCodeList} from 'c/countryCodeList'
import currencyConverterAssets from '@salesforce/resourceUrl/currencyConverterAssets'
export default class CurrencyConverterApp extends LightningElement {
    countryList=countryCodeList;
    countryFrom="USD"
    countryTo="INR"
    result;
    error;
    amount='';

    currencyImage=currencyConverterAssets+ '/currencyConverterAssets/currency.svg'

    handleChange(event){
        const {name,value}=event.target;

        console.log("name"+name);
        console.log("value"+value);
        this[name]=value;

        console.log(this.amount);

        this.result='';
        this.error='';
    }

    submitHandler(event){
      event.preventDefault();
      this.convert();
    }

  async convert(){
       const API_URL=`https://api.exchangerate.host/convert?from=${this.countryFrom}&to=${this.countryTo}`;
       try{
        const data= await fetch(API_URL);
        const jsonData=data.json();
        jsonData.then(res=>{
            this.result=(Number(this.amount) * res.result).toFixed(2);
            console.log("res.result"+res.result)
            console.log("result"+this.result);
        }).catch(err=>{
            this.error='error Occured please try again!'
            console.log(err);
        })
        console.log("json data"+jsonData);
       }catch(error){
          console.log(error);
       }
         
    } 
}
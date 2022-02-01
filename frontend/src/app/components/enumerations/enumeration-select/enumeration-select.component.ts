import {Component, EventEmitter, Input, OnInit, Output} from '@angular/core';
import {Enumeration} from "../enumeration.model";


@Component({
  selector: 'op-enumeration-select',
  templateUrl: './enumeration-select.component.html',
  styleUrls: ['./enumeration-select.component.sass']
})
export class EnumerationSelectComponent implements OnInit {
  @Input() enumerations:Enumeration[] | undefined;
  @Input() enumerationLabel:string = 'Выберите тип показателя';
  @Input() selectedEnumeration:Enumeration | undefined;
  @Output() outputSelectedEnumeration = new EventEmitter<any>();
  @Input() disabled:boolean = false;

  constructor() {
    //
  }

  ngOnInit():void {
    //
  }

  onChange(newValue:any) {
    this.selectedEnumeration = newValue;
    this.outputSelectedEnumeration.emit(newValue);
  }

  compareFn(c1:Enumeration, c2:Enumeration):boolean {
    return c1 && c2 ? c1.id === c2.id : c1 === c2;
  }

  disableSelect() {
    this.disabled = true;
  }

  enableSelect() {
    this.disabled = false;
  }

}

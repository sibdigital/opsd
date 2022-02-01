import {Component, Input, OnInit} from '@angular/core';
import {MatTreeFlatDataSource, MatTreeFlattener} from "@angular/material/tree";
import {FlatTreeControl} from "@angular/cdk/tree";
import * as moment from 'moment';
import {PurposeCriteria} from "core-components/el-budget/execution/purpose-criteria/purpose-criteria.model";
import {PurposeCriteriaMonthlyExecutions} from "core-components/el-budget/execution/purpose-criteria/purpose-criteria-monthly-executions.model";
moment.locale('ru-RU');


interface PurposeCriteriaNode {
  name:string;
  children?:PurposeCriteriaNode[];
}

interface FlatNode {
  expandable:boolean;
  name:string;
  level:number;
}

@Component({
  selector: 'op-purpose-criteria-view',
  templateUrl: './purpose-criteria-view.component.html',
  styleUrls: ['./purpose-criteria-view.component.sass']
})
export class PurposeCriteriaViewComponent implements OnInit {
  @Input() purposeCriteria:PurposeCriteria | undefined;
  tree_data:PurposeCriteriaNode[];

  private _transformer = (node:PurposeCriteriaNode, level:number) => {
    return {
      expandable: !!node.children && node.children.length > 0,
      name: node.name,
      level: level,
    };
  }

  treeControl = new FlatTreeControl<FlatNode>(
    node => node.level, node => node.expandable);

  treeFlattener = new MatTreeFlattener(
    this._transformer, node => node.level, node => node.expandable, node => node.children);

  dataSource = new MatTreeFlatDataSource(this.treeControl, this.treeFlattener);

  hasChild = (_:number, node:FlatNode) => node.expandable;

  constructor() {
    this.tree_data = [];
    if (this.purposeCriteria) {
      this.tree_data.push({
        name: 'MetaId показателя: ' + this.purposeCriteria.purposeCriteriaMetaId,
        children: this.getNodeByPurposeCriteria(this.purposeCriteria)
      });
      this.dataSource.data = this.tree_data;
    }
  }

  ngOnInit():void {
    this.tree_data = [];
    if (this.purposeCriteria) {
      this.tree_data = this.getNodeByPurposeCriteria(this.purposeCriteria);
      this.dataSource.data = this.tree_data;
    }
  }

  parsePurposeCriteriaList(purposeCriteria:PurposeCriteria):void {
    this.tree_data = this.getNodeByPurposeCriteria(purposeCriteria);

    this.dataSource.data = this.tree_data;
  }

  getNodeByPurposeCriteria(purposeCriteria:PurposeCriteria):PurposeCriteriaNode[] {
    return [
      {
        name: 'Описание',
        children: [{
          name: purposeCriteria.description,
        }]
      },
      {
        name: 'Показатели по месяцам',
        children: this.getNodeByPurposeCriteriaMonthlyExecutions(purposeCriteria.purposeCriteriaMonthlyExecutions)
      },
    ];
  }

  getNodeByPurposeCriteriaMonthlyExecutions(purposeCriteriaMonthlyExecutions:PurposeCriteriaMonthlyExecutions | null):PurposeCriteriaNode[] {
    var node:PurposeCriteriaNode[] = [];

    if (purposeCriteriaMonthlyExecutions) {

      let pcmes = purposeCriteriaMonthlyExecutions.purposeCriteriaMonthlyExecution; // PurposeCriteriaMonthlyExecution[]
      if (pcmes) {
        pcmes.sort((a, b) => {
          return a.month - b.month;
        });

        pcmes.forEach(monthlyExecution => {
          let month:number = Number(monthlyExecution.month) + 1;
          // let month: number = monthlyExecution.month + 1;
          node.push({
            name: moment(month, 'M').locale('ru').format('MMMM').toLocaleUpperCase() + "; Значение: " + monthlyExecution.factPrognos,
          });
        });
      }
    }

    return node;
  }
}

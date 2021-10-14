import {Component, Input} from '@angular/core';
import {MatTreeNestedDataSource} from "@angular/material/tree";
import {NestedTreeControl} from "@angular/cdk/tree";
interface ShortPage {
  id:number;
  title:string;
  children:ShortPage[];
}
@Component({
  selector: 'op-page-view-navigation',
  templateUrl: './navigation.component.html',
  styleUrls: ['./navigation.component.sass']
})
export class NavigationComponent {
  treeControl = new NestedTreeControl<ShortPage>(node => node.children);
  @Input()
  dataSource = new MatTreeNestedDataSource<ShortPage>();
  constructor(){
  }

  hasChild = (_:number, node:ShortPage) => node.children.length > 0;
  isEnd = (_:number, node:ShortPage) => node.children.length === 0;
}

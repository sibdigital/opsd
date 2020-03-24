import {Component, ViewChild} from "@angular/core";
import {AngularTrackingHelpers} from "core-components/angular/tracking-functions";
import {HomescreenBlueTableComponent} from "core-components/homescreen-blue-table/homescreen-blue-table.component";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {StateService} from "@uirouter/core";

interface ValueOption {
  name:string;
  dueDate:string;
  $href:number | null;
}

@Component({
  templateUrl: './kpi-tab.html'
})
export class KpiTabComponent {
  public dueDate:string = '';
  private value:{ [attribute:string]:any } | undefined = {};
  public valueOptions:ValueOption[] = [];
  keyword = 'name';
  data_autocomplete:any[] = [];
  data_choosed:any;
  is_loading:boolean[] = [true];
  public compareByHref = AngularTrackingHelpers.compareByHref;

  @ViewChild(HomescreenBlueTableComponent) blueChild:HomescreenBlueTableComponent;
  @ViewChild('autocomplete') auto:any;

  constructor(protected halResourceService:HalResourceService,
              protected pathHelper:PathHelperService,
              readonly $state:StateService) {
  }

  ngOnInit() {
    this.halResourceService.get<CollectionResource<HalResource>>(this.pathHelper.api.v3.projects_for_user.toString())
      .toPromise()
      .then((projects:CollectionResource<HalResource>) => {
        this.valueOptions = projects.elements.map((el:HalResource) => {
          this.data_autocomplete.push({id: el.id, name: el.name, dueDate: el.dueDate.due_date});
          return {
            name: el.name,
            dueDate: el.dueDate.due_date,
            $href: el.id
          };
        });
        this.valueOptions.unshift({name: 'Все проекты', dueDate: '', $href: 0});
        this.value = this.valueOptions[0];
        if (this.$state.params.id) {
          let option:ValueOption | undefined = _.find(this.valueOptions, o => String(o.$href) === this.$state.params.id);
          if (option !== undefined) {
            this.selectedOption = option;
          }
        }
        this.is_loading[0] = false;
      });
  }

  public get selectedOption() {
    const href = this.value ? this.value.$href : null;
    return _.find(this.valueOptions, o => o.$href === href)!;
  }

  public set selectedOption(val:ValueOption) {
    let option = _.find(this.valueOptions, o => o.$href === val.$href);
    this.value = option;
  }

  public check_load() {
    // console.log(this.is_loading);
    return this.is_loading[0];

    // let is_ready = true;
    // this.is_loading.forEach(value => (is_ready = value || is_ready));
    // return is_ready;
  }

  public handleUserSubmit() {
    if (this.selectedOption) {
      this.blueChild.changeFilter('project' + this.selectedOption.$href);
      this.dueDate = this.format(this.selectedOption.dueDate);
    }
  }

  public selectEvent(item:any) {
    this.auto.close();
    this.is_loading[0] = true;
    this.data_choosed = item;
    this.blueChild.changeFilter('project' + this.data_choosed.id);
    this.dueDate = this.format(this.data_choosed.dueDate);
    this.is_loading[0] = false;
  }

  public format(input:string):string {
    return input.slice(8, 10) + '.' + input.slice(5, 7) + '.' + input.slice(0, 4);
  }
}

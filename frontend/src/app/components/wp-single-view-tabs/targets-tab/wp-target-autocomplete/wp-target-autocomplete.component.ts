import {Component, ElementRef, EventEmitter, Input, OnInit, Output} from '@angular/core';
import {PathHelperService} from "app/modules/common/path-helper/path-helper.service";
import {LoadingIndicatorService} from "app/modules/common/loading-indicator/loading-indicator.service";
import {I18nService} from "app/modules/common/i18n/i18n.service";
import {WorkPackageResource} from "app/modules/hal/resources/work-package-resource";
import {TargetResource} from "core-app/modules/hal/resources/target-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";

@Component({
  selector: 'wp-target-autocomplete',
  templateUrl: './wp-target-autocomplete.component.html',
})
export class WpTargetAutocompleteComponent implements OnInit {
  readonly text = {
    placeholder: this.I18n.t('js.target_buttons.placeholder')
  };

  @Input() workPackage: WorkPackageResource;
  @Input() filterCandidatesFor:string;
  @Input() initialSelection?:TargetResource;
  @Input() inputPlaceholder:string = this.text.placeholder;
  @Input() appendToContainer:string = '#content';

  @Output('onTargetIdSelected') public onSelect = new EventEmitter<string|null>();
  @Output('onEscape') public onEscapePressed = new EventEmitter<KeyboardEvent>();
  @Output('onBlur') public onBlur = new EventEmitter<FocusEvent>();

  public options:any = [];
  public relatedWps:any = [];
  public noResults = false;

  private $element:JQuery;
  private $input:JQuery;

  constructor(readonly elementRef:ElementRef,
              readonly pathHelper:PathHelperService,
              readonly halResourceService: HalResourceService,
              readonly loadingIndicatorService:LoadingIndicatorService,
              readonly I18n:I18nService) {
  }

  ngOnInit() {
    this.$element = jQuery(this.elementRef.nativeElement);
    const input = this.$input = this.$element.find('.wp-target--autocomplete');
    let selected = false;

    if (this.initialSelection) {
      input.val(this.getIdentifier(this.initialSelection));
    }

    input.autocomplete({
      delay: 250,
      autoFocus: false, // Accessibility!
      appendTo: this.appendToContainer,
      classes: {
        'ui-autocomplete': 'wp-target-autocomplete--results'
      },
      source: (request:{ term:string }, response:Function) => {
        this.loadTargets().then((values) => {
          selected = false;

          if (this.initialSelection) {
            values.unshift(this.initialSelection);
          }

          response(values.map((wp:any) => {
            return {target: wp, value: this.getIdentifier(wp)};
          }));
        });
      },
      select: (evt, ui:any) => {
        selected = true;
        this.onSelect.emit(ui.item.target.id);
      },
      minLength: 0
    })
      .focus(() => !selected && input.autocomplete('search', input.val() as string));

    setTimeout(() => input.focus(), 20);
  }

  ngOnDestroy():void {
    this.$input.autocomplete('destroy');
  }

  public handleEnterPressed($event:KeyboardEvent) {
    let val = ($event.target as HTMLInputElement).value;
    if (!val) {
      this.onSelect.emit(null);
    }

    // If trying to enter work package ID
    if (val.match(/^#?\d+$/)) {
      val = val.replace(/^#/, '');
      this.onSelect.emit(val);
    }
  }

  private getIdentifier(target:TargetResource):string {
    if (target) {
      return `#${target.id} - ${target.name}`;
    } else {
      return '';
    }
  }

  private loadTargets(){
    //return this.wpTargetService.getTargets(this.workPackage.project.getId());
    return this.halResourceService
      .get<HalResource>(this.pathHelper.api.v3.targets.toString(), {'project_id': this.workPackage.project.getId()})
      .toPromise()
      .then((collection:CollectionResource) => {return collection.elements || [];});
 }
}

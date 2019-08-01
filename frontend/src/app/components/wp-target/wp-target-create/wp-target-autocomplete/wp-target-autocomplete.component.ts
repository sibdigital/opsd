import {Component, ElementRef, EventEmitter, Input, OnInit, Output} from '@angular/core';
//import {WorkPackageResource} from "core-app/modules/hal/resources/work-package-resource";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {LoadingIndicatorService} from "core-app/modules/common/loading-indicator/loading-indicator.service";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {
  PeriodicElement,
  WpRelationsDialogComponent
} from "core-components/wp-relations/wp-relations-create/wp-relations-dialog/wp-relations-dialog.component";
import {TargetResource} from "core-app/modules/hal/resources/target-resource";
import {WpTargetsService} from "core-components/wp-target/wp-targets.service";
import {WorkPackageResource} from "core-app/modules/hal/resources/work-package-resource";

@Component({
  selector: 'wp-target-autocomplete',
  templateUrl: './wp-target-autocomplete.component.html',
})
export class WpTargetAutocompleteComponent implements OnInit {
  readonly text = {
    placeholder: this.I18n.t('js.target_autocomplete.placeholder')
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
              readonly wpTargetService: WpTargetsService,
              readonly pathHelper:PathHelperService,
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
    return this.wpTargetService.getTargets(this.workPackage.project.id);
  }

  // private autocompleteTargets(query:string):Promise<TargetResource> {
  //   // Remove prefix # from search
  //   query = query.replace(/^#/, '');
  //
  //   this.$element.find('.ui-autocomplete--loading').show();
  //
  //   return this.wpTargetService.getTargets('1')
  //       .then((collection:CollectionResource) => {
  //           this.noResults = collection.count === 0;
  //           this.$element.find('.ui-autocomplete--loading').hide();
  //           return collection.elements || [];
  //         }).catch(() => {
  //           this.$element.find('.ui-autocomplete--loading').hide();
  //           return [];
  //         });
  //
  //   // return this.targets.fetch({
  //   //   query: query,
  //   //   type: this.filterCandidatesFor
  //   // }).then((collection:CollectionResource) => {
  //   //   this.noResults = collection.count === 0;
  //   //   this.$element.find('.ui-autocomplete--loading').hide();
  //   //   return collection.elements || [];
  //   // }).catch(() => {
  //   //   this.$element.find('.ui-autocomplete--loading').hide();
  //   //   return [];
  //   // });
  // }

}

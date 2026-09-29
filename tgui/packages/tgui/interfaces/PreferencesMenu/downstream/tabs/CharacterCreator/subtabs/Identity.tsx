import { LabeledGridList } from 'pm/components';
import { useBackendStrict } from 'tgui/backend';
import { Button, Dropdown, Section, Stack } from 'tgui-core/components';

export const SubtabIdentityDownstreamPaneLeft = () => {
  // Suggested format:
  // return (
  //   <>
  //     <Stack.Item>
  //       <MyCardHere />
  //     </Stack.Item>
  //     <Stack.Item>
  //       <MyCardHere2 />
  //     </Stack.Item>
  //   </>
  // )

  return null;
};

export const SubtabIdentityDownstreamPaneRight = () => {
  return (
    <>
      <Stack.Item>
        <SubtabIdentityCardDreamValley />
      </Stack.Item>
      <Stack.Item>
        <SubtabIdentityCardAdultContent />
      </Stack.Item>
    </>
  );
};

type DreamValleyData = {
  dv_have_manor: boolean;
  dv_manor_name: string;
  dv_manor_type: string;
  dv_manor_type_options: string[];
  dv_content: Record<string, boolean>;
  dv_scent_type: string;
  dv_scent_text: string;
};

const ADULT_CONTENT = [
  ['erp_panel', 'ERP Panel', 'Let others use ERP panel interactions on you.'],
  ['erp_visuals', 'ERP Visual Effects', 'Hearts and screen effects during ERP.'],
  ['chastity', 'Chastity Content', 'See and interact with chastity devices.'],
  ['permanent_binding', 'Permanent Binding', 'Chastity devices can only be opened with their own key.'],
  ['extreme_erp', 'Extreme ERP Content', 'Show the extreme categories in the ERP panel.'],
  ['edging', 'Edging', 'Allow edging content in the ERP panel.'],
  ['cursed_collars', 'Cursed Collars', 'Let others put a cursed collar on you.'],
] as const;

const SubtabIdentityCardAdultContent = () => {
  const { act, data } = useBackendStrict<DreamValleyData>();

  return (
    <Section title="Adult Content">
      <LabeledGridList>
        {ADULT_CONTENT.map(([id, label, tooltip]) => (
          <LabeledGridList.Item key={id} label={label}>
            <Button.Checkbox
              fluid
              checked={!!data.dv_content?.[id]}
              tooltip={tooltip}
              onClick={() => act('dv_toggle_content', { id })}
            >
              {data.dv_content?.[id] ? 'On' : 'Off'}
            </Button.Checkbox>
          </LabeledGridList.Item>
        ))}
      </LabeledGridList>
    </Section>
  );
};

const SubtabIdentityCardDreamValley = () => {
  const { act, data } = useBackendStrict<DreamValleyData>();

  return (
    <Section title="DreamValley">
      <LabeledGridList>
        <LabeledGridList.Item label="Origin Map">
          <Button fluid icon="map" onClick={() => act('dv_open_origin_map')}>
            Choose origin on the map
          </Button>
        </LabeledGridList.Item>
        <LabeledGridList.Item label="Character Creation">
          <Button fluid icon="scroll" onClick={() => act('dv_open_tat')}>
            Stats, skills, traits, quirks and loadout
          </Button>
        </LabeledGridList.Item>
        <LabeledGridList.Item label="Scent">
          <Dropdown
            width="100%"
            selected={data.dv_scent_type}
            options={['Pleasant', 'Neutral', 'Gross']}
            onSelected={(value) => act('dv_set_scent_type', { value })}
          />
        </LabeledGridList.Item>
        <LabeledGridList.Item label="Smells Of">
          <Button
            fluid
            ellipsis
            tooltip="Only noticed if you take the Redolent quirk."
            onClick={() => act('dv_set_scent_text')}
          >
            {data.dv_scent_text}
          </Button>
        </LabeledGridList.Item>
        <LabeledGridList.Item label="Manor">
          <Button.Checkbox
            fluid
            checked={data.dv_have_manor}
            onClick={() => act('dv_toggle_have_manor')}
          >
            {data.dv_have_manor ? 'Holds a manor' : 'No manor'}
          </Button.Checkbox>
        </LabeledGridList.Item>
        {!!data.dv_have_manor && (
          <>
            <LabeledGridList.Item label="Manor Name">
              <Button fluid onClick={() => act('dv_set_manor_name')}>
                {data.dv_manor_name || 'Unnamed'}
              </Button>
            </LabeledGridList.Item>
            <LabeledGridList.Item label="Manor Type">
              <Dropdown
                width="100%"
                selected={data.dv_manor_type}
                options={data.dv_manor_type_options || []}
                onSelected={(value) => act('dv_set_manor_type', { value })}
              />
            </LabeledGridList.Item>
          </>
        )}
      </LabeledGridList>
    </Section>
  );
};

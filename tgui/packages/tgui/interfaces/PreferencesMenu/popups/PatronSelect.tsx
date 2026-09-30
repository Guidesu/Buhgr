import { PrefPopupGuard } from 'pm/components';
import {
  type PopupData,
  registerPopup,
  useKeyscrollEffect,
  usePopupBackend,
} from 'pm/popups';
import { useState } from 'react';
import {
  Box,
  Button,
  Icon,
  Input,
  Section,
  Stack,
  Tabs,
  TextArea,
} from 'tgui-core/components';

type DomainGod = {
  type: string;
  name: string;
  domain: string;
  desc: string;
  worshippers: string;
};

type Domain = {
  type: string;
  name: string;
  desc: string;
  icon: string;
  pray_hint: string;
  gods: DomainGod[];
  miracles: string[];
};

export type PopupPatronSelectData = {
  domains: Domain[];
  selected_domain: string;
  selected_patron: string;
  custom: boolean;
  custom_name: string;
  custom_titles: string;
  custom_desc: string;
  name_max: number;
  titles_max: number;
  desc_max: number;
} & PopupData;

const PopupPatronSelect = () => {
  const { data } = usePopupBackend<PopupPatronSelectData>();
  const { popup_data_ready } = data;

  return (
    <PrefPopupGuard
      title="Domain & God"
      loadingScreenText="Domains Loading..."
      width="80vw"
      height="80vh"
      dependencies={[popup_data_ready]}
    >
      <PopupPatronSelectInner />
    </PrefPopupGuard>
  );
};

declare module 'pm/popups' {
  interface PopupRegistry {
    PatronSelect: 'patron_select';
  }
}
registerPopup('PatronSelect', 'patron_select', PopupPatronSelect);

const PopupPatronSelectInner = () => {
  const { data } = usePopupBackend<PopupPatronSelectData>();
  const domains = data.domains || [];
  const [viewing, setViewing] = useState(data.selected_domain);
  const domainTypes = domains.map((d) => d.type);

  useKeyscrollEffect({
    list: domainTypes,
    currentIndex: domainTypes.indexOf(viewing),
    setter: (v) => setViewing(v),
  });

  const domain = domains.find((d) => d.type === viewing) || domains[0];

  return (
    <Stack fill>
      <Stack.Item basis="22%">
        <Section fill scrollable title="Domains">
          <Tabs vertical>
            {domains.map((d) => (
              <Tabs.Tab
                key={d.type}
                icon={d.icon}
                selected={d.type === domain?.type}
                onClick={() => setViewing(d.type)}
                rightSlot={
                  d.type === data.selected_domain ? (
                    <Icon name="check" />
                  ) : undefined
                }
              >
                {d.name}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        {domain ? <DomainPane domain={domain} /> : null}
      </Stack.Item>
    </Stack>
  );
};

const DomainPane = (props: { domain: Domain }) => {
  const { domain } = props;
  const { data, act } = usePopupBackend<PopupPatronSelectData>();
  const isSelected = data.selected_domain === domain.type;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section
          title={
            <>
              <Icon name={domain.icon} mr={1} />
              {domain.name}
            </>
          }
          buttons={
            <Button
              disabled={isSelected}
              icon={isSelected ? 'check' : undefined}
              onClick={() => act('set_domain', { domain: domain.type })}
            >
              {isSelected ? 'My domain' : 'Serve this domain'}
            </Button>
          }
        >
          <Box mb={1}>{domain.desc}</Box>
          <Box color="label" mb={1}>
            <Icon name="hands-praying" mr={1} />
            Pray at {domain.pray_hint}.
          </Box>
          <Box>
            {domain.miracles.map((m) => (
              <Box
                key={m}
                inline
                px={1}
                mr={0.5}
                mb={0.5}
                style={{
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  fontSize: '11px',
                }}
              >
                {m}
              </Box>
            ))}
          </Box>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title="Gods of this domain">
          {!isSelected && (
            <Box color="label" italic mb={1}>
              Serve this domain to choose one of its gods.
            </Box>
          )}
          {domain.gods.map((god) => (
            <GodCard key={god.type} god={god} enabled={isSelected} />
          ))}
          <CustomGodCard enabled={isSelected} />
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const GodCard = (props: { god: DomainGod; enabled: boolean }) => {
  const { god, enabled } = props;
  const { data, act } = usePopupBackend<PopupPatronSelectData>();
  const chosen = enabled && !data.custom && data.selected_patron === god.type;

  return (
    <Section
      title={god.name}
      buttons={
        <Button
          disabled={!enabled || chosen}
          icon={chosen ? 'check' : undefined}
          onClick={() => act('set_patron', { patron: god.type })}
        >
          {chosen ? 'Worshipped' : 'Worship'}
        </Button>
      }
    >
      <Box color="label" mb={0.5}>
        {god.domain}
      </Box>
      <Box mb={0.5} dangerouslySetInnerHTML={{ __html: god.desc }} />
      {!!god.worshippers && (
        <Box color="label" italic>
          Worshipped by {god.worshippers}
        </Box>
      )}
    </Section>
  );
};

const CustomGodCard = (props: { enabled: boolean }) => {
  const { enabled } = props;
  const { data, act } = usePopupBackend<PopupPatronSelectData>();
  const chosen = enabled && data.custom;

  return (
    <Section
      title="A god of my own"
      buttons={
        <Button
          disabled={!enabled || chosen}
          icon={chosen ? 'check' : 'feather'}
          onClick={() => act('use_custom')}
        >
          {chosen ? 'Worshipped' : 'Write my own'}
        </Button>
      }
    >
      <Box color="label" mb={1}>
        On Palimpseste, belief makes a god. Name yours and it will hear you.
        Prayers that speak its name or one of its titles please it most.
      </Box>
      {chosen && (
        <Stack vertical>
          <Stack.Item>
            <Box bold mb={0.5}>
              Name
            </Box>
            <Input
              fluid
              maxLength={data.name_max}
              value={data.custom_name}
              placeholder="The god's name"
              onBlur={(v) => act('set_custom_name', { value: v })}
              onEnter={(v) => act('set_custom_name', { value: v })}
            />
          </Stack.Item>
          <Stack.Item>
            <Box bold mb={0.5}>
              Titles <Box inline color="label">(comma separated)</Box>
            </Box>
            <Input
              fluid
              maxLength={data.titles_max}
              value={data.custom_titles}
              placeholder="The Harrow-Mother, She Who Waits"
              onBlur={(v) => act('set_custom_titles', { value: v })}
              onEnter={(v) => act('set_custom_titles', { value: v })}
            />
          </Stack.Item>
          <Stack.Item>
            <Box bold mb={0.5}>
              Description
            </Box>
            <TextArea
              fluid
              height="6em"
              maxLength={data.desc_max}
              value={data.custom_desc}
              placeholder="Who is this god, and what do they ask of their faithful?"
              onBlur={(v) => act('set_custom_desc', { value: v })}
            />
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
};

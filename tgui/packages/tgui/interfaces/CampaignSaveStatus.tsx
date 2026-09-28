import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type CharacterRow = {
  uid: string;
  owner: string;
  name: string;
  in_world: BooleanLike;
  saved_at: string;
  location: string;
  bed: string | null;
};

type SlotRow = {
  name: string;
  readable: BooleanLike;
  saved_at: string | null;
  in_game_day: number | null;
  characters: number;
};

type CampaignRow = {
  id: string;
  last_saved: string | null;
  active: BooleanLike;
};

type Data = {
  is_admin: BooleanLike;
  can_shutdown: BooleanLike;
  enabled: BooleanLike;
  campaign_id: string;
  frozen_reason: string | null;
  last_saved: string;
  loaded_slot: string;
  my_characters: CharacterRow[];
  boot_slot?: string;
  slots?: SlotRow[];
  all_characters?: CharacterRow[];
  campaigns?: CampaignRow[];
};

const AUTOSAVE = 'autosave';

export const CampaignSaveStatus = () => {
  const { data } = useBackend<Data>();
  const { is_admin, enabled, frozen_reason } = data;

  return (
    <Window title="Campaign" width={680} height={is_admin ? 780 : 420}>
      <Window.Content scrollable>
        {!enabled && (
          <NoticeBox color="bad">
            Campaign saving is turned off on this server.
          </NoticeBox>
        )}
        {!!frozen_reason && <NoticeBox color="caution">{frozen_reason}</NoticeBox>}
        <OverviewSection />
        <MyCharactersSection />
        {!!is_admin && (
          <>
            <WorldSavesSection />
            <AllCharactersSection />
            <CampaignsSection />
          </>
        )}
      </Window.Content>
    </Window>
  );
};

const OverviewSection = () => {
  const { act, data } = useBackend<Data>();
  const { is_admin, can_shutdown, campaign_id, last_saved, loaded_slot } =
    data;

  return (
    <Section
      title="World"
      buttons={
        <>
          {!!is_admin && (
            <Button icon="save" onClick={() => act('save_now')}>
              Save Now
            </Button>
          )}
          {!!can_shutdown && (
            <Button
              icon="power-off"
              color="caution"
              onClick={() => act('save_and_shutdown')}
            >
              Save and Shut Down
            </Button>
          )}
        </>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Campaign">{campaign_id}</LabeledList.Item>
        <LabeledList.Item label="Last saved">{last_saved}</LabeledList.Item>
        {!!is_admin && (
          <LabeledList.Item label="Started from">
            {loaded_slot === AUTOSAVE ? 'the autosave' : `"${loaded_slot}"`}
          </LabeledList.Item>
        )}
      </LabeledList>
      <Box mt={1} color="label">
        The world saves itself every few minutes and when the server shuts
        down.
      </Box>
    </Section>
  );
};

const CharacterWhere = (props: { row: CharacterRow }) => {
  const { row } = props;
  if (row.in_world) {
    return <>Playing now</>;
  }
  return row.bed ? <>Asleep in a bed at {row.bed}</> : <>At {row.location}</>;
};

const MyCharactersSection = () => {
  const { act, data } = useBackend<Data>();
  const { my_characters } = data;

  return (
    <Section title="My Saved Characters">
      {!my_characters.length ? (
        <Box color="label">
          You have no saved characters. Sleeping in a bed or using Far Travel
          saves your character; resume them from the lobby with Saved
          Characters.
        </Box>
      ) : (
        <Table>
          <Table.Row header>
            <Table.Cell>Name</Table.Cell>
            <Table.Cell>Where</Table.Cell>
            <Table.Cell>Saved</Table.Cell>
            <Table.Cell collapsing />
          </Table.Row>
          {my_characters.map((row) => (
            <Table.Row key={row.uid}>
              <Table.Cell bold>{row.name}</Table.Cell>
              <Table.Cell>
                <CharacterWhere row={row} />
              </Table.Cell>
              <Table.Cell>{row.saved_at}</Table.Cell>
              <Table.Cell collapsing>
                {!!row.bed && (
                  <Button
                    icon="bed"
                    tooltip="Wake up where you last were instead of in this bed"
                    onClick={() => act('forget_bed', { uid: row.uid })}
                  >
                    Forget Bed
                  </Button>
                )}
                {!row.in_world && (
                  <Button
                    icon="trash"
                    color="bad"
                    onClick={() => act('delete_character', { uid: row.uid })}
                  >
                    Delete
                  </Button>
                )}
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
};

const WorldSavesSection = () => {
  const { act, data } = useBackend<Data>();
  const { slots = [], boot_slot } = data;

  return (
    <Section
      title="World Saves"
      buttons={
        <Button icon="plus" onClick={() => act('save_to_slot')}>
          Save As New
        </Button>
      }
    >
      <Box mb={1} color="label">
        The server loads the save marked "Next start". Choosing another save
        only affects the next restart; "Load Now" restarts immediately.
      </Box>
      {!slots.length ? (
        <Box color="label">No saves yet.</Box>
      ) : (
        <Table>
          <Table.Row header>
            <Table.Cell>Save</Table.Cell>
            <Table.Cell>Saved</Table.Cell>
            <Table.Cell>Day</Table.Cell>
            <Table.Cell>Characters</Table.Cell>
            <Table.Cell collapsing />
          </Table.Row>
          {slots.map((slot) => (
            <Table.Row key={slot.name}>
              <Table.Cell bold>
                {slot.name === AUTOSAVE ? 'Autosave' : slot.name}
                {slot.name === boot_slot && (
                  <Box inline color="good" ml={1}>
                    (Next start)
                  </Box>
                )}
              </Table.Cell>
              {slot.readable ? (
                <>
                  <Table.Cell>{slot.saved_at}</Table.Cell>
                  <Table.Cell>{slot.in_game_day ?? '-'}</Table.Cell>
                  <Table.Cell>{slot.characters}</Table.Cell>
                </>
              ) : (
                <Table.Cell colSpan={3} color="bad">
                  Damaged - can't be loaded
                </Table.Cell>
              )}
              <Table.Cell collapsing>
                {slot.name !== AUTOSAVE && (
                  <Button
                    icon="save"
                    tooltip="Overwrite with the current world"
                    onClick={() => act('save_to_slot', { slot: slot.name })}
                  />
                )}
                <Button
                  icon="clock"
                  disabled={!slot.readable || slot.name === boot_slot}
                  onClick={() => act('load_next_boot', { slot: slot.name })}
                >
                  Next Start
                </Button>
                <Button
                  icon="undo"
                  color="caution"
                  disabled={!slot.readable}
                  onClick={() => act('load_now', { slot: slot.name })}
                >
                  Load Now
                </Button>
                {slot.name !== AUTOSAVE && (
                  <Button
                    icon="trash"
                    color="bad"
                    onClick={() => act('delete_slot', { slot: slot.name })}
                  />
                )}
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
};

const AllCharactersSection = () => {
  const { act, data } = useBackend<Data>();
  const { all_characters = [] } = data;

  return (
    <Section title="Everyone's Saved Characters">
      {!all_characters.length ? (
        <Box color="label">No saved characters.</Box>
      ) : (
        <Table>
          <Table.Row header>
            <Table.Cell>Name</Table.Cell>
            <Table.Cell>Player</Table.Cell>
            <Table.Cell>Where</Table.Cell>
            <Table.Cell>Saved</Table.Cell>
            <Table.Cell collapsing />
          </Table.Row>
          {all_characters.map((row) => (
            <Table.Row key={row.uid}>
              <Table.Cell bold>{row.name}</Table.Cell>
              <Table.Cell>{row.owner}</Table.Cell>
              <Table.Cell>
                <CharacterWhere row={row} />
              </Table.Cell>
              <Table.Cell>{row.saved_at}</Table.Cell>
              <Table.Cell collapsing>
                <Button
                  icon="trash"
                  color="bad"
                  onClick={() => act('delete_character', { uid: row.uid })}
                />
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
};

const CampaignsSection = () => {
  const { act, data } = useBackend<Data>();
  const { campaigns = [] } = data;

  return (
    <Section
      title="Campaigns"
      buttons={
        <Button icon="plus" onClick={() => act('create_campaign')}>
          New Campaign
        </Button>
      }
    >
      <Table>
        <Table.Row header>
          <Table.Cell>Campaign</Table.Cell>
          <Table.Cell>Last saved</Table.Cell>
          <Table.Cell collapsing />
        </Table.Row>
        {campaigns.map((row) => (
          <Table.Row key={row.id}>
            <Table.Cell bold={!!row.active}>
              {row.id}
              {!!row.active && ' (current)'}
            </Table.Cell>
            <Table.Cell>{row.last_saved || 'Never'}</Table.Cell>
            <Table.Cell collapsing>
              {!row.active && (
                <>
                  <Button
                    icon="exchange-alt"
                    onClick={() =>
                      act('switch_campaign', { campaign_id: row.id })
                    }
                  >
                    Switch To
                  </Button>
                  <Button
                    icon="trash"
                    color="bad"
                    onClick={() =>
                      act('delete_campaign', { campaign_id: row.id })
                    }
                  />
                </>
              )}
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

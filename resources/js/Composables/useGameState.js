import {ref} from "vue";

export const gameStates = {
    InProgress: 'InProgress',
    Stalemate: 'Stalemate',
    XWins: 'XWins',
    OWins: 'OWins',
};

export const useGameState = () => {
    const state = ref(gameStates.InProgress);

    return {
        change: (newState) => state.value = newState,
        current: () => state.value,
        hasEnded: () => [gameStates.XWins, gameStates.OWins, gameStates.Stalemate].includes(state.value),
    };
};
